#!/bin/bash

# Takes a pcap-file and extracts the first 6 bytes of each packet in 
# the following format. The output is intended to be used in a later 
# analysis step (e.g. python) as input. Packets without TCP payload 
# get ignored.
#
# example:
#
# timeInSecondsSinceEpoch;source;destination;databytes
# 1710411296.845277;192.168.0.105.8888;192.168.0.183.64016;000000012764
# 1710411296.845301;192.168.0.105.8888;192.168.0.183.64016;019eac8b31d4
# 1710411296.845351;192.168.0.105.8888;192.168.0.183.64016;32d0c168303e
# 1710411296.845364;192.168.0.105.8888;192.168.0.183.64016;52a3f5e18e2f
# 1710411296.877550;192.168.0.105.8888;192.168.0.183.64016;00000001219a

DATABYTE_CHAR_COUNT=12

if [ ! -e "$1" ]; then
   echo "ERROR: missing input file"
   exit 1
fi

lineCount=0

tcpdump -r $1 -nn -x -q -tt \
 | sed -E 's/([0-9]+\.[0-9]*)/@\1;/' \
 | sed -E 's/([^;]+);.*IP\s*([0-9]+\.[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+)\s+>\s+([0-9]+\.[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+): tcp ([0-9]+).*/\1;\4;\2;\3;/' \
 | sed -E 's/\s*0x[0-9a-fA-F]+:\s+//' \
 | tr -d ' ' \
 | tr -d '\n' \
 | tr '@' '\n' \
 | while read line; do
      if [ ${#line} -le 0 ]; then
         continue
      fi
      dataByteCount=$(echo -n "$line" | cut --delimiter=";" --fields=2)
      if [ $dataByteCount -eq 0 ]; then
         continue
      fi
      charCount=$(expr $dataByteCount "*" "-2")
      dataBytes=$(echo -n "$line" | cut --delimiter=";" --fields=5)
      prefix=$(echo -n "$line" | cut --delimiter=";" --fields=1,3,4)
      if [ $lineCount -eq 0 ]; then
         echo "timeInSecondsSinceEpoch;source;destination;databytes"
      fi
      echo "$prefix;${dataBytes: $charCount: $DATABYTE_CHAR_COUNT}"
      lineCount=$(expr $lineCount + 1)
done

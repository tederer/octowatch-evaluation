#!/bin/bash

POLLING_INTERVAL_IN_MS=1000

function getTimeInMs
{
   secondsSinceEpoch=$(date +%s)
   nanos=$(date +%N)
   echo "${secondsSinceEpoch}${nanos:0:3}"
}

function msToSeconds
{
   local millis=$1
   
   while [ ${#millis} -lt 4 ]; do
      millis="0$millis"
   done
   
   secondsLength=$(expr ${#millis} - 3)
   echo "${millis:0:$secondsLength}.${millis:$secondsLength}"
}

echo "timestamp;temperature;humidity"
while [ true ]; do
   isoTimestamp=$(date --iso-8601=ns)
   pollingStartInMs=$(getTimeInMs)
   
   value=$(/home/tux/octowatch-monitoring/readDht20.sh)
   
   pollingEndInMs=$(getTimeInMs)

   echo "$isoTimestamp;$value"
   sleepDurationInMs=$(expr $POLLING_INTERVAL_IN_MS - "(" $pollingEndInMs - $pollingStartInMs ")")
   if [ $sleepDurationInMs -gt 0 ]; then
      sleepDurationInSec=$(msToSeconds $sleepDurationInMs)
      sleep $sleepDurationInSec
   fi
   lastPollingInMs=$pollingStartInMs
done

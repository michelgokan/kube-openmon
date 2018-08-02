#!/bin/bash

if [[ -z "${MONITORING_INTERVAL}" ]]; then
   SLEEP_TIME="1"
else
   SLEEP_TIME="${MONITORING_INTERVAL}"
fi

while :
do
   perl /opt/collect_and_push.pl
   sleep $SLEEP_TIME
done

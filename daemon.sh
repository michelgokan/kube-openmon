#!/bin/bash

if [[ -z "${MONITORING_INTERVAL}" ]]; then
   SLEEP_TIME="1"
else
   SLEEP_TIME="${MONITORING_INTERVAL}"
fi

nodes=`curl https://${KUBERNETES_PORT_443_TCP_ADDR}:${KUBERNETES_PORT_443_TCP_PORT}/api/v1/nodes/ --header "Authorization: Bearer $TOKEN" --insecure | awk '$1 ~ /^\"name\":$/{ gsub("\"","",$2); gsub(",","",$2); print $2 }'`


while :
do
   for word in $nodes
   do
      if [ "${ENABLED}" == "1" ]; then
         perl /opt/collect_and_push.pl $word & 
      else
         echo "Disabled!"
      fi
   done
   sleep $SLEEP_TIME
done

#!/bin/bash

if [[ -z "${MONITORING_INTERVAL}" ]]; then
   SLEEP_TIME="1"
else
   SLEEP_TIME="${MONITORING_INTERVAL}"
fi



while :
do
    nodesInfo=`curl https://${KUBERNETES_PORT_443_TCP_ADDR}:${KUBERNETES_PORT_443_TCP_PORT}/api/v1/nodes/ --header "Authorization: Bearer ${KUBERNETES_CUSTOM_TOKEN}" --insecure`
    nodes=`printf "$nodesInfo" | awk '$1 ~ /^\"name\":$/{ gsub("\"","",$2); gsub(",","",$2); print $2 }'`

   for node in $nodes
   do
      if [ "${ENABLED}" == "1" ]; then
         nodeAllocatableResources=`printf "$nodesInfo" | jq ".items[] | select(.metadata.name == \"$node\") | .status.allocatable"`
         nodeAllocatableCPU=`printf "$nodeAllocatableResources" | jq -r '.cpu'`
         nodeAllocatableMemory=`printf "$nodeAllocatableResources" | jq -r '.memory'`
         nodeAllocatableMemory=${nodeAllocatableMemory%??}
         nodeAllocatableDisk=`printf "$nodeAllocatableResources" | jq -r '."ephemeral-storage"'`

         perl /opt/collect_and_push.pl $node $nodeAllocatableCPU $nodeAllocatableMemory $nodeAllocatableDisk &
      else
         echo "Disabled!"
      fi
   done
   sleep $SLEEP_TIME
done

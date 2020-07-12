#!/usr/bin/env bash

COLLECTOR_IP=$(kubectl get services/collector-service -o jsonpath='{.status.loadBalancer.ingress[0].ip}')
COLLECTOR_URL="${COLLECTOR_IP}/i"

echo "Checking collector state under: ${COLLECTOR_IP}"
echo

for i in 1 2 3 4 5 6 7 8 9 10
do
    echo "Ping: ${i}"
    is_not_ok=$(curl -I --silent "${COLLECTOR_URL}" | grep HTTP | grep 200)

    if [[ "${is_not_ok}" == "" ]]; then
        echo "It seems that the collector is not running"
        echo
        echo $(curl -I --silent "${COLLECTOR_URL}" | grep HTTP)
        exit 1
    fi
done

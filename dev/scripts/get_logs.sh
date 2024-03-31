#!/bin/bash

POD_LABEL="app=syslog-ng"
TIMESTAMP=$(date +"%Y-%m-%d_%H%M%S")
DESTINATION="../logs/messages_$TIMESTAMP.log"
POD_NAME=$(kubectl get pod -n default -l $POD_LABEL -o jsonpath="{.items[0].metadata.name}")

kubectl cp -n default "$POD_NAME:/var/log/messages.log" "$DESTINATION"


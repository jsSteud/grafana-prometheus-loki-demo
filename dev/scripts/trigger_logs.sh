#!/bin/bash

# PORT FORWARDING
local_port_start=7777
label_selector="app=microservice"
namespace="default"

if [ -z "$namespace" ]; then
  pods=$(kubectl get pods --selector=$label_selector --output=jsonpath='{.items[*].metadata.name}')
else
  pods=$(kubectl get pods -n $namespace --selector=$label_selector --output=jsonpath='{.items[*].metadata.name}')
fi

for pod in $pods; do
  local_port=$((local_port_start++))

  if [ -z "$namespace" ]; then
    kubectl port-forward $pod $local_port:3000 &
  else
    kubectl port-forward -n $namespace $pod $local_port:3000 &
  fi
  
done


start_port=7777
end_port=7786

endpoints=("v1/status/201/" "v1/status/401/" "v1/status/404/")

while true; do
  port=$((RANDOM % (end_port - start_port + 1) + start_port))
  endpoint=${endpoints[$RANDOM % ${#endpoints[@]}]}
  url="http://localhost:$port/$endpoint"
  
  echo "Anfrage an: $url"
  response=$(curl -s -o /dev/null -w "%{http_code}" $url)
  echo "Antwort-Status: $response"
  
  sleep 1
done

#!/bin/bash

# Start- und Endwert für die Portreichweite definieren
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

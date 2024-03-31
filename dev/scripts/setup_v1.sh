#!/bin/bash

# CLUSTER SETUP 

# kill everything
docker rmi -f $(docker images | grep 'dummy-microservice' | awk '{print $3}') && \ || true
minikube delete && \ || true

# start minikube with mounting conf for syslog
# TODO: dont commit
minikube start --mount --mount-string="/Users/jaschasteudler/Documents/university/Module/Current/Bachelorarbeit/Code/Syslog/config:/syslog-conf" && \

# build MS-Image and load it into minikube
docker build -t dummy-microservice ../../Microservice && \
minikube image load dummy-microservice && \

# deploy K8s cluster
kubectl apply -f ../../K8s/deployments/deployment-ms.yml && \
kubectl apply -f ../../K8s/deployments/deployment-syslog.yml && \
kubectl apply -f ../../K8s/deployments/deployment-debug-pod.yml && \
helm install log-exporter oci://registry-1.docker.io/bitnamicharts/node-exporter && \

# Check every second if the container is ready, then continue
POD_LABEL="app=syslog-ng"
echo "Waiting for syslog to be ready (this will take some time) ..."
while true; do
    # Get the status of pods based on label and filter for 'Running' status
    POD_STATUS=$(kubectl get pods -l $POD_LABEL -o jsonpath="{.items[0].status.phase}")

    # If the pod is Running, break the loop and continue
    if [[ "$POD_STATUS" == "Running" ]]; then
        echo "Syslog is ready."
        break
    else
        sleep 1
    fi
done

POD_NAME=$(kubectl get pod -l $POD_LABEL -o jsonpath="{.items[0].metadata.name}")

# Create the file /var/log/messages.log inside the Pod
kubectl exec $POD_NAME -- touch /var/log/messages.log && \

# Change the permissions of /var/log/messages.log inside the Pod
kubectl exec $POD_NAME -- chmod -R a+rwX /var/log/messages.log && \



# ------------------------------------------------------------------------------------
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

# ------------------------------------------------------------------------------------
# SETUP PROMETHEUS & GRAFANA

# Prometheus
kubectl create configmap prometheus-config --from-file=../../K8s/config/prometheus.yml && \
kubectl apply -f ../../K8s/deployments/deployment-prometheus.yml

# Grafana
kubectl create configmap grafana-config --from-file=../../K8s/config/grafana.ini && \
kubectl apply -f ../../K8s/deployments/deployment-grafana.yml && \

echo "Waiting for grafana to be ready (this will take some time)..."
while true; do
    # Get the status of pods based on label and filter for 'Running' status
    POD_STATUS=$(kubectl get pods -l app=grafana -o jsonpath="{.items[0].status.phase}")

    # If the pod is Running, break the loop and continue
    if [[ "$POD_STATUS" == "Running" ]]; then
        echo "Grafana is ready."
        break
    else
        sleep 1
    fi
done

kubectl port-forward $(kubectl get pod -l app=grafana -o jsonpath="{.items[0].metadata.name}") 3000:3000 

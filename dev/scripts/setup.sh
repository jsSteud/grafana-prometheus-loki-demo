#!/bin/bash

# Remove existing resources
docker rmi -f $(docker images | grep 'dummy-microservice' | awk '{print $3}')
minikube delete

# Start Minikube
minikube start

# Build microservice image and load it into Minikube
docker build -t dummy-microservice ../../Microservice
# this is because:
# https://github.com/kubernetes/minikube/issues/18021#issuecomment-1953589210
docker image save -o image.tar dummy-microservice:latest
minikube image load image.tar

# Add Helm repositories and update
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo add grafana https://grafana.github.io/helm-charts
helm repo update

# Install Prometheus and expose
helm install prometheus prometheus-community/prometheus
kubectl expose service prometheus-server --type=NodePort --target-port=9090 --name=prometheus-server-ext
minikube service prometheus-server-ext

# Install Grafana and expose
helm install grafana grafana/grafana
kubectl expose service grafana --type=NodePort --target-port=3000 --name=grafana-ext

# Install Loki
helm upgrade --install loki --namespace=default grafana/loki-stack --set loki.image.tag=2.9.3

# Deploy Kubernetes resources
kubectl apply -f ../../K8s/deployments/deployment-ms.yml
kubectl apply -f ../../K8s/deployments/deployment-debug-pod.yml

# Check if all pods are running in the default namespace
while [[ $(kubectl get pods --namespace=default --no-headers | grep -v -E "Running|Completed" | wc -l) -gt 0 ]]; do
    echo "Waiting for all pods to be in Running state..."
    sleep 5
done

echo "All pods in default namespace are running."

label_selector="app.kubernetes.io/instance=grafana"
namespace="default"
pod=$(kubectl get pods --selector=$label_selector --output=jsonpath='{.items[*].metadata.name}')
kubectl port-forward $pod 3000:3000 &



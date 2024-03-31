#!/bin/bash

# Remove existing resources
docker rmi -f $(docker images | grep 'dummy-microservice' | awk '{print $3}')
minikube delete

# Start Minikube
minikube start

# Build microservice image and load it into Minikube
docker build -t dummy-microservice ../../Microservice
minikube image load dummy-microservice

# Deploy Kubernetes resources
kubectl apply -f ../../K8s/deployments/deployment-ms.yml
kubectl apply -f ../../K8s/deployments/deployment-debug-pod.yml

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
minikube service grafana-ext

# Display username and password for Grafana
echo "Username:"
kubectl get secret --namespace default grafana -o jsonpath="{.data.admin-user}" | base64 --decode
echo "Password:"
kubectl get secret --namespace default grafana -o jsonpath="{.data.admin-password}" | base64 --decode

# Install Loki
helm upgrade --install loki --namespace=default grafana/loki-stack --set loki.image.tag=2.9.3
^
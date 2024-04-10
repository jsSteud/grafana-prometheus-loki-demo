# Grafana - Prometheus - Loki DEMO

This repo is for you, if you want to test Grafana-Prometheus in a Kubernetes architeture. It's a step-by-step guide to do the first steps with grafana.

## Description

This project is part of a bachelor thesis. It should offer the possibility to test the usage of Grafana, Prometheus, and Loki. In the context of the bachelor's thesis, it serves to demonstrate a monitoring tool for microservices in Kubernetes environments.

## Getting Started

### Dependencies

* [Docker](https://docs.docker.com/engine/install/)
* [minikube](https://minikube.sigs.k8s.io/docs/start/)
* [kubectl](https://kubernetes.io/docs/tasks/tools/)
* [helm](https://helm.sh/docs/intro/install/)
* [Open Lens](https://github.com/lensapp/lens) (just a recommendation, not a dependency)

### 1. Installing (TL;DR)

* run `dev/scripts/setup.sh`

    Warning: this scripts kills your current minikube configuration!

Thats it!

### 2. How to use?

* Grafa is now reachable over [127.0.0.1:3000](127.0.0.1:3000)
* Login (Information to login as admin was printed in console output)

### 3. Let's add Prometheus and Loki as data sources
* Click...
    1. Burger-Menu in the left upper corner
    2. "Connection"
    3. Search for "Prometheus"
    4. "Add new data source" in the upper right corner
    5. Type for "Prometheus server URL": `http://prometheus-server:80`
    6. Scroll down and click "Save & test"
    7. Repeat for Loki with URL: `http://loki:3100`

### 4. Let's produce some logs

The following script is responsible to produce logs. The microservices, running as pods in your cluster, are dummy-services just here to produce logs. With this script we trigger them. Let's go!

* run `dev/scripts/trigger_logs.sh`

### 5. Let's checkout Grafana with Loki (below is a guide for Prometheus)

Now we want to add dashboards to monitor our microservices. Therefore:
* Click....
    1. Burger-Menu in the left upper corner
    2. Dashboard
    3. Click Dashboard
    4. Add visualization
    5. Choose Loki 
    6. Enter as loki query `{namespace="default", pod="<microservicePodNameHere>"}`
    7. Run query


### 5. Let's checkout Grafana with Prometheus

Now we want to add dashboards to monitor our Kubernetes cluster. Therefore:
* Click....
    1. Burger-Menu in the left upper corner
    2. Dashboard
    3. Click Dashboard
    4. Add visualization
    5. Choose Prometheus 
    6. Enter as PromQl query `container_cpu_usage_seconds_total{pod="podNameHere", namespace="default"}`
    7. Run query




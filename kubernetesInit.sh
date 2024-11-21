#!/bin/bash

echo "Initializing Kubernetes cluster..."

kubectl apply -f kubernetes/deployment.yaml
kubectl apply -f kubernetes/depl-service.yaml
kubectl apply -f kubernetes/ingress.yaml
kubectl apply -f kubernetes/ingress.yaml

echo "Kubernetes cluster initialized successfully."
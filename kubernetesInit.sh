#!/bin/bash

echo "Initializing Kubernetes cluster..."
# Update kubeconfig
aws eks --region eu-central-1 update-kubeconfig --name huba-eks-tf-cluster

cd terraform_cluster  
terraform apply -auto-approve ||
cd .. ||
kubectl apply -f kubernetes/deployment.yaml ||
kubectl apply -f kubernetes/depl-service.yaml ||
kubectl apply -f kubernetes/ingress.yaml ||
kubectl apply -f kubernetes/ingress.yaml ||

echo "Kubernetes cluster initialized successfully."
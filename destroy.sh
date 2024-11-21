#!/bin/bash

echo "Destroying infrastructure..."

kubectl apply -f kubernetes/deployment.yaml 
kubectl apply -f kubernetes/depl-service.yaml 
kubectl apply -f kubernetes/ingress.yaml 
kubectl apply -f kubernetes/ingress.yaml 

cd terraform_cluster || terraform destroy -auto-approve
echo "Infrastructure successfully."
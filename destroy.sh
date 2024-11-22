#!/bin/bash

# Check if the AWS CLI is logged in
if ! aws sts get-caller-identity &> /dev/null; then
  echo "Error: AWS CLI is not logged in. Please configure your AWS credentials."
  exit 1
fi

echo "Destroying Kubernetes cluster..."

set -x

# Delete the secrets, deployments, services, configmaps, persistent volumes, and persistent volume claims
kubectl delete  -f kubernetes/postgres-configmap.yaml && \
kubectl delete  -f kubernetes/postgres-pv.yaml && \
kubectl delete  -f kubernetes/postgres-pvc.yaml && \
kubectl delete  -f kubernetes/postgres-secret.yaml && \
kubectl delete  -f kubernetes/postgres-deployment.yaml && \
kubectl delete  -f kubernetes/postgres-service.yaml && \
kubectl delete  -f kubernetes/configmap.yaml && \
kubectl delete  -f kubernetes/gameserver-service.yaml && \
kubectl delete  -f kubernetes/gameserver-deployment.yaml && \
kubectl delete  -f kubernetes/load-balancer.yaml && \
kubectl delete  -f kubernetes/ingress.yaml && \

# Destroy the Kubernetes cluster
cd terraform_cluster && \
terraform destroy -auto-approve && \
cd .. && \

# Update kubeconfig
aws eks --region eu-central-1 update-kubeconfig --name huba-eks-tf-cluster && \

echo "Kubernetes cluster destroyed successfully."
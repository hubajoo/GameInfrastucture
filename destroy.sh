#!/bin/bash

if ! aws sts get-caller-identity &> /dev/null; then
  echo "Error: AWS CLI is not logged in. Please configure your AWS credentials."
  exit 1
fi

echo "Initializing Kubernetes cluster..."

set -x


kubectl delete --validate=false -f kubernetes/deployment.yaml && \
kubectl delete --validate=false -f kubernetes/depl-service.yaml && \
kubectl delete --validate=false -f kubernetes/ingress.yaml && \
kubectl delete --validate=false -f kubernetes/ingress.yaml && \
cd terraform_cluster && \
terraform destroy -auto-approve && \
cd .. && \
# Update kubeconfig
aws eks --region eu-central-1 update-kubeconfig --name huba-eks-tf-cluster && \

echo "Kubernetes cluster initialized successfully."
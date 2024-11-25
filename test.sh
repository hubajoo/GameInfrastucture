#!/bin/bash

# Verify dependencies
if ! bash ./dependency-check.sh; then
  echo "Error: Dependencies not met. Please check the error messages above."
  exit 1
fi &&\

# Check if terraform plan detects differences in the infrastructure
echo "Verifying Terraform plan..."

cd terraform_cluster && \
if ! terraform plan -detailed-exitcode &> /dev/null; then
  echo "Error: Terraform plan detected differences in the infrastructure. Please run the start.sh script."
  exit 1
fi && cd .. &&\

echo "Terrform state verified." &&\

# Check if the Kubernetes configuration files are present
echo "Verifying Kubernetes configuration files..." &&\

KubeFiles=(
  "kubernetes/postgres-configmap.yaml"
  "kubernetes/postgres-pv.yaml"
  "kubernetes/postgres-pvc.yaml"
  "kubernetes/postgres-secret.yaml"
  "kubernetes/postgres-deployment.yaml"
  "kubernetes/postgres-service.yaml"
  "kubernetes/gameserver-configmap.yaml"
  "kubernetes/gameserver-service.yaml"
  "kubernetes/gameserver-deployment.yaml"
  "kubernetes/load-balancer.yaml"
  "kubernetes/ingress.yaml"
) &&\

# Itarate over the array of files
for file in "${KubeFiles[@]}"; do
  if [ ! -f "$file" ]; then
    echo "Error: Kubernetes configuration file $file not found. Please run the start.sh script."
    exit 1
  fi
done &&\

echo "Kubernetes configuration files verified." &&\

# Check if the kubernetes resources are successfully created
echo "Verifying Kubernetes resources..." &&\

for file in "${KubeFiles[@]}"; do
  if ! kubectl get -f "$file" &> /dev/null; then
    echo "Error: Kubernetes resources not found. Please run the start.sh script."
    exit 1
  fi
done

echo "Kubernetes resources verified."
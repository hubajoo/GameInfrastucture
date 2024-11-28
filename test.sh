#!/bin/bash

# Define colors for the output
GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m' # No Color


# Verify dependencies
if ! bash ./utility-scripts/dependency-check.sh; then
  echo -e "${RED}Error: Dependencies not met. Please check the error messages above.${NC}\n"
  exit 1
fi &&\

# Check if terraform plan detects differences in the infrastructure
echo "Verifying Terraform plan..."

cd terraform_cluster && \
if ! terraform plan -detailed-exitcode &> /dev/null; then
  echo -e "${RED}Error: Terraform plan detected differences in the infrastructure. Please run the start.sh script.${NC}"
  echo "In case of local deployment, this is expected."
fi && cd .. &&\

echo "Terraform state verified." &&\

# Check if the Kubernetes configuration files are present
echo "Verifying Kubernetes configuration files..." &&\

KubeFiles=(
  "kubernetes/gameserver-configmap.yaml"
  "kubernetes/gameserver-service.yaml"
  "kubernetes/gameserver-deployment.yaml"
  "kubernetes/load-balancer.yaml"
  "kubernetes/ingress.yaml"
  "postgres/postgres-configmap.yaml"
  "postgres/postgres-init-configmap.yaml"
  "postgres/postgres-deployment.yaml"
  "postgres/postgres-service.yaml"
  "terraform_cluster/kubernetes/storage-class.yaml"
  "terraform_cluster/kubernetes/postgres-pv.yaml"
  "terraform_cluster/kubernetes/postgres-claim.yaml"
) &&\


# Itarate over the array of files
for file in "${KubeFiles[@]}"; do
  if [ ! -f "$file" ]; then
    echo -e  "${RED}Error: Kubernetes configuration file $file not found. Replace missing files.${NC}"
    exit 1
  fi
done &&\

echo "Kubernetes configuration files verified." &&\

# Check if the kubernetes resources are successfully created
echo "Verifying Kubernetes resources..." &&\

for file in "${KubeFiles[@]}"; do
  if ! kubectl get -f "$file" &> /dev/null; then
    echo -e "${RED}Error: Kubernetes resource not found. Please run the start.sh script ($file)${NC}."
    echo "In case of local deployment, the resources from terraform_cluster resources are expected to be missing."
  fi
done

echo -e "Tests finished"
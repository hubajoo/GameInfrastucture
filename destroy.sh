#!/bin/bash

# Verify dependencies
if ! bash ./dependency-check.sh; then
  echo "Error: Dependencies not met. Please check the error messages above."
  exit 1
fi &&\

echo "Destroying resources..."

# Function to delete a resource
delete_resource(){

  # Extract the arguments
  local resource=$1
  local file=$2
  local retries=5
  local count=0

  # If no file argument is provided
  if [ -z "$file" ]; then

    # Check if there is a resource file with the same name
    if [ -f "$resource" ]; then
      # Set the file to the resource name
      file=$resource
    fi

    # Check if there is a file in the Kubernetes directory with the correct name
    if [ -f "kubernetes/$resource" ]; then

      # Set the file to the resource name with the Kubernetes directory prefix
      file="kubernetes/$resource"
    fi

      # Check if there is a .yaml file in the Kubernetes directory with the correct name
    if [ -f "kubernetes/$resource.yaml" ]; then

      # Set the file to the resource name with the Kubernetes directory prefix and .yaml suffix
      file="kubernetes/$resource.yaml"
    fi

  fi

  # Check if the resource exists
  if [ ! -f "$file" ] || ! kubectl get -f "$file" &> /dev/null; then

    # Skip if the resource does not exist
    echo "$resource file not found, skipping..."
    return

  fi

  # Delete the resource with retries
  while [ $count -lt $retries ]; do

    # Exit the loop if the deletion is successful
    kubectl delete -f $file && break 

    # Exit the loop if the resource is not found
    if kubectl delete -f $file 2>&1 | grep -q "NotFound"; then 
      echo "$resource not found on deletion attempt, skipping..."
      break
    fi

    # Log the retry and wait, then reattempt the deletion
    count=$((count + 1))
    echo "Retrying to delete $resource ($count/$retries)..."
    sleep 5
  done

  # Force delete the resource if it still exists
  if [ $count -eq $retries ]; then
    echo "Force deleting $resource..."
    kubectl delete -f $file --grace-period=0 --force
  fi
}

# Delete the secrets, deployments, services, configmaps, persistent volumes, and persistent volume claims
delete_resource "postgres-configmap" "kubernetes/postgres-configmap.yaml"
delete_resource "postgres-pvc" "kubernetes/postgres-pvc.yaml"
delete_resource "postgres-pv" "kubernetes/postgres-pv.yaml"
delete_resource "postgres-secret" "kubernetes/postgres-secret.yaml"
delete_resource "postgres-deployment" "kubernetes/postgres-deployment.yaml"
delete_resource "postgres-service" "kubernetes/postgres-service.yaml"
delete_resource "configmap" "kubernetes/configmap.yaml"
delete_resource "gameserver-service" "kubernetes/gameserver-service.yaml"
delete_resource "gameserver-deployment" "kubernetes/gameserver-deployment.yaml"
delete_resource "load-balancer" "kubernetes/load-balancer.yaml"
delete_resource "ingress" "kubernetes/ingress.yaml"

# Destroy the EKS cluster
echo "Destroying cluster..."
cd terraform_cluster && \
terraform destroy -auto-approve && \
cd .. && \

# Unset the environment variables
unset POSTGRES_USER
unset POSTGRES_PASSWORD
unset POSTGRES_DB

# Unset the encoded environment variables
unset POSTGRES_USER_ENCODED
unset POSTGRES_PASSWORD_ENCODED
unset POSTGRES_DB_ENCODED

echo "Infrastructure successfully destroyed."
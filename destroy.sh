#!/bin/bash

# Define colors for the output
GREEN='\033[0;32m'
RED='\033[0;31m'
GRAY='\033[1;30m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Verify dependencies
if ! bash ./dependency-check.sh; then
  echo -e "${RED}Error: Dependencies not met. Please check the error messages above.${NC}\n"
  exit 1
fi &&\

echo "Destroying resources..."

# Function to delete a resource
delete_resource(){

  # Extract the arguments
  local file=$1
  local resource=$2
  local retries=5
  local count=0

  # Extract resource name
  resource=$(basename "$file" .yaml)


  # Check if the resource exists
  if [ ! -f "$file" ] || ! kubectl get -f "$file" &> /dev/null; then

    # Skip if the resource does not exist
    echo -e "${GRAY}$resource file not found, skipping...${NC}"
    return
  fi

 echo -e "${GRAY}Deleting $resource...${NC}"
  # Delete the resource with retries
  while [ $count -lt $retries ]; do
    kubectl delete -f $file
    if [ $? -eq 0 ]; then
      echo -e "${GRAY}$resource deleted successfully.${NC}"
      break
    elif kubectl get -f $file 2>&1 | grep -q "NotFound"; then
      echo -e "${GRAY}$resource not found on deletion attempt, skipping...${NC}"
      break
    fi

    # Log the retry and wait, then reattempt the deletion
    count=$((count + 1))
    echo "Retrying to delete $resource ($count/$retries)..."
    sleep 5
  done

  # Force delete the resource if it still exists
  if [ $count -eq $retries ]; then
    echo "${YELLOW}Force deleting $resource...${NC}"
    kubectl delete -f $file --grace-period=0 --force
    return
  fi
  return
}


# Iterate through the resources in the kubernetes directory
for resource in kubernetes/*; do
  delete_resource $resource "kubernetes/$resource"
done

# Iterate through the resources in the postgres directory
for resource in postgres/*; do
  delete_resource $resource "postgres/$resource"
done



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

echo "\n${GREEN}Infrastructure successfully destroyed.${NC}\n"
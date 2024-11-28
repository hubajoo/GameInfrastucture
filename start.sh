#!/bin/bash

# Define colors for the output
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
GRAY='\033[1;30m'
NC='\033[0m' # No Color

# Prompt the user if they want to create a new cluster or use their default cluster

while [ "$new_cluster" != "yes" ] && [ "$new_cluster" != "no" ]; do
read -r -p "    Do you want to use dedicated cluster? (yes/no): " new_cluster
if [ "$new_cluster" == "yes" ]; then

  # Execute the eks-setup.sh script
  bash ./utility-scripts/eks-setup.sh

fi
done


while [ "$minikube" != "yes" ] && [ "$minikube" != "no" ] && [ "$new_cluster" == "no" ]; do
read -r -p "    Are you using minikube? - Limited functionality available only (yes/no): " minikube
done


# Use dependency-check.sh to verify dependencies
if ! bash ./utility-scripts/dependency-check.sh $minikube; then
  echo -e "${RED}Error: Dependencies not met. Please check the error messages above.${NC}\n"
  exit 1
fi

# Load environment variables from .env file
if [ -f .env ]; then
  export $(cat .env | xargs)

  # Check if the required variables are set
  if [ -z "$POSTGRES_USER" ] || [ -z "$POSTGRES_PASSWORD" ] || [ -z "$POSTGRES_DB" ]; then
    echo -e "${RED}Error: Required variables not found in .env file. Please check the .env file.${NC}"
    exit 1
  fi

# If the .env file is not found or the variables are not set
else
  read -p "The .env file is not valid, do you want to proceed with default settings? (yes/no): " default_settings
  if [ "$default_settings" == "yes" ]; then
    export POSTGRES_USER="admin"
    export POSTGRES_PASSWORD="password"
    export POSTGRES_DB="leaderboard"
  fi

  # If the user does not want to proceed with default settings exit
  echo "Exiting..."
  exit 1
fi

echo "Building infrastructure..."


# Create the configmap YAML
cat <<EOF > postgres/postgres-configmap.yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: postgres-config
  labels:
    app: postgres
data:
  POSTGRES_DB: $POSTGRES_DB
  POSTGRES_USER: $POSTGRES_USER
  POSTGRES_PASSWORD: $POSTGRES_PASSWORD

EOF


# Function to create a resource
create_resource(){

  # Extract the arguments
  local resource=$1


  # Number of retries for creating resources
  local retries=5

  # Check if the file exists
  if [ ! -f "$resource" ]; then
    echo "$resource file not found, skipping..."
    return
  fi

  echo -e "${GRAY}Creating $resource...${NC}"

  # Create the resource with retries
  local count=0
  while [ $count -lt $retries ]; do
    kubectl apply -f "$resource"
    if [ $? -eq 0 ]; then
      echo -e "${GRAY}$resource created successfully.${NC}"
      break
    fi

    # Log the retry and wait, then reattempt the creation
    count=$((count + 1))
    echo -e "${YELLOW}Retrying to create $resource ($count/$retries)...${NC}"
    sleep 5
  done
  return
}


# If the user uses the default cluster, create a pv (otherwise it will be created by the terraform script)
if [ "$new_cluster" == "no" ]; then

  # Create the LoadBalancer service
  for resource in local-config/*; do
  create_resource "$resource"
  done
fi && \


# Iterate through the resources in the kubernetes directory
for resource in kubernetes/*; do
  create_resource "$resource"
done && \


# Iterate through the resources in the postgres directory
for resource in postgres/*; do
  create_resource "$resource"
done && \



if [ "$new_cluster" == "yes" ]; then

  # Wait for the LoadBalancer to get an external IP
  EXTERNAL_IP=""
  echo "Waiting for LoadBalancer to get an external IP..."
  while [ -z $EXTERNAL_IP ]; do
    echo "Waiting for external IP..."
    EXTERNAL_IP=$(kubectl get svc gameserver-deployment-loadbalancer -o jsonpath='{.status.loadBalancer.ingress[0].hostname}')
    [ -z $EXTERNAL_IP ] && sleep 3
  done 
fi


# MiniKube handling
if [ "$minikube" == "yes" ]; then

  echo -e "\n   ${YELLOW}In minikube we can't get the external IP of the LoadBalancer.${NC}"

   # MiniKube command needs an open terminaly so we can't extract the IP
   echo    "   To access the site, run the following command in the terminal:"
   echo -e "   ${GREEN}minikube service  gameserver-deployment-loadbalancer --url ${NC}"
   echo -e "   (You might gave to allow tunneling)\n"
 
  # Exit, because we don't need to update the ConfigMap and restart the deployments
 exit 1
fi

# Update the ConfigMap with the external IP
kubectl patch configmap gameserver-config -p "{\"data\":{\"LOADBALANCER_IP\":\"$EXTERNAL_IP\", \"POSTGRES_DB\":\"$POSTGRES_DB\", \"POSTGRES_USER\":\"$POSTGRES_USER\", \"POSTGRES_PASSWORD\":\"$POSTGRES_PASSWORD\"}}"


# Restart the server deployment to pick up the new environment variable
kubectl rollout restart deployment gameserver-deployment && \

# Check the status of the deployment
kubectl rollout status deployment gameserver-deployment && \

echo -e "${GREEN}\nKubernetes cluster initialized successfully.${NC}"
echo -e "${GREEN}Site is available at http://$EXTERNAL_IP \n${NC}"

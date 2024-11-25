#!/bin/bash

# Use dependency-check.sh to verify dependencies
if ! bash ./dependency-check.sh; then
  echo "Error: Dependencies not met. Please check the error messages above."
  exit 1
fi

# Load environment variables from .env file
if [ -f .env ]; then
  export $(cat .env | xargs)

  # Check if the required variables are set
  if [ -z "$POSTGRES_USER" ] || [ -z "$POSTGRES_PASSWORD" ] || [ -z "$POSTGRES_DB" ]; then
    echo "Error: Required variables not found in .env file. Please check the .env file."
    exit 1
  fi

# If the .env file is not found or the variables are not set
else
  read -p "The .env file is not valid, do you want to proceed with default settings? (yes/no): " default_settings
  if [ "$default_settings" == "yes" ]; then
    export POSTGRES_USER="postgres"
    export POSTGRES_PASSWORD="password"
    export POSTGRES_DB="leaderboard"
  fi

  # If the user does not want to proceed with default settings exit
  echo "Exiting..."
  exit 1
fi

echo "Dependencies verified."

echo "Building infrastructure..."


# Set environment variables for PostgreSQL credentials


# Encode the environment variables
POSTGRES_USER_ENCODED=$(echo -n "$POSTGRES_USER" | base64)
POSTGRES_PASSWORD_ENCODED=$(echo -n "$POSTGRES_PASSWORD" | base64)
POSTGRES_DB_ENCODED=$(echo -n "$POSTGRES_DB" | base64)

# Create the secret YAML
cat <<EOF > kubernetes/postgres-secret.yaml
apiVersion: v1
kind: Secret
metadata:
  name: postgres-secret
type: Opaque
data:
  POSTGRES_USER: $POSTGRES_USER_ENCODED
  POSTGRES_PASSWORD: $POSTGRES_PASSWORD_ENCODED
  POSTGRES_DB: $POSTGRES_DB_ENCODED
EOF

#set -x

# Change to the terraform_cluster directory and apply the Terraform configuration
cd terraform_cluster && \
terraform apply -auto-approve && \
cd .. && \

# Update kubeconfig
aws eks --region eu-central-1 update-kubeconfig --name huba-eks-tf-cluster && \


# Apply the Kubernetes manifests
kubectl apply -f kubernetes/postgres-configmap.yaml && \
kubectl apply -f kubernetes/postgres-pv.yaml && \
kubectl apply -f kubernetes/postgres-pvc.yaml && \
kubectl apply -f kubernetes/postgres-secret.yaml && \
kubectl apply -f kubernetes/postgres-deployment.yaml && \
kubectl apply -f kubernetes/postgres-service.yaml && \
kubectl apply -f kubernetes/gameserver-configmap.yaml && \
kubectl apply -f kubernetes/gameserver-service.yaml && \
kubectl apply -f kubernetes/gameserver-deployment.yaml && \
kubectl apply -f kubernetes/load-balancer.yaml && \
kubectl apply -f kubernetes/ingress.yaml && \


# Wait for the LoadBalancer to get an external IP
EXTERNAL_IP=""
echo "Waiting for LoadBalancer to get an external IP..."
while [ -z "$EXTERNAL_IP" ]; do
  echo "Waiting for external IP..."
  EXTERNAL_IP=$(kubectl get svc gameserver-deployment-loadbalancer -o jsonpath='{.status.loadBalancer.ingress[0].hostname}')
  [ -z "$EXTERNAL_IP" ] && sleep 3
done 

echo "LoadBalancer External IP: $EXTERNAL_IP"

# Update the ConfigMap with the external IP
kubectl patch configmap gameserver-config -p "{\"data\":{
                                              \"LOADBALANCER_IP\":\"$EXTERNAL_IP\",
                                              \"POSTGRES_USER\":\"$POSTGRES_USER\",
                                              \"POSTGRES_PASSWORD\":\"$POSTGRES_PASSWORD\",
                                              \"POSTGRES_DB\":\"$POSTGRES_DB\"}}" && \

kubectl set env --keys="LOADBALANCER_IP" --from=configmap/gameserver-config deployment/gameserver-deployment

# Restart the deployment to pick up the new environment variable
kubectl rollout restart deployment gameserver-deployment && \

# Check the status of the deployment
kubectl rollout status deployment gameserver-deployment && \

echo "Kubernetes cluster initialized successfully."
echo "Site is available at http://$EXTERNAL_IP"

#!/bin/bash

# Check if the AWS CLI is logged in
if ! aws sts get-caller-identity &> /dev/null; then
  echo "Error: AWS CLI is not logged in. Please configure your AWS credentials."
  exit 1
fi

echo "Initializing Kubernetes cluster..."

set -x
# Change to the terraform_cluster directory and apply the Terraform configuration
cd terraform_cluster && \
terraform apply -auto-approve && \
# Update kubeconfig
aws eks --region eu-central-1 update-kubeconfig --name huba-eks-tf-cluster && \
cd .. && \
# Apply the Kubernetes manifests
kubectl apply --validate=false -f kubernetes/configmap.yaml && \
kubectl apply --validate=false  -f kubernetes/deployment.yaml && \
kubectl apply --validate=false -f kubernetes/depl-service.yaml && \
kubectl apply --validate=false -f kubernetes/load-balancer.yaml && \
kubectl apply --validate=false -f kubernetes/ingress.yaml && \


# Wait for the LoadBalancer to get an external IP
echo "Waiting for LoadBalancer to get an external IP..."
sleep 60  # Adjust the sleep time as needed

# Output the LoadBalancer's external IP
EXTERNAL_IP=$(kubectl get svc gameserver-deployment-loadbalancer -o jsonpath='{.status.loadBalancer.ingress[0].ip}')
echo "LoadBalancer External IP: $EXTERNAL_IP"

# Update the ConfigMap with the external IP
kubectl patch configmap gameserver-config -p "{\"data\":{\"LOADBALANCER_IP\":\"$EXTERNAL_IP\"}}"

# Restart the deployment to pick up the new environment variable
kubectl rollout restart deployment gameserver-deployment


echo "Kubernetes cluster initialized successfully."
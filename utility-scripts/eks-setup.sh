#!/bin/bash

# Create a new cluster
printf "Starting terraform...\n"

# Change to the terraform_cluster directory and apply the Terraform configuration
cd terraform_cluster && \
printf "Creating cluster...\n" && \
#terraform init && \
#terraform apply -auto-approve && \

# Update kubeconfig
aws eks --region eu-central-1 update-kubeconfig --name huba-eks-tf-cluster

# Extract tf outputs
postgres_volume_id=$(terraform output -raw postgres_volume_id) &&\

printf "Creating persistent storage for Postgres...\n"

# Create the PV configuration
cat <<EOF > kubernetes/postgres-pv.yaml
apiVersion: v1
kind: PersistentVolume
metadata:
  name: postgres-volume
  labels:
    type: local
    app: postgres
spec:
  storageClassName: ""
  capacity:
    storage: 2Gi
  accessModes:
    - ReadWriteMany
  awsElasticBlockStore:
    volumeID: $postgres_volume_id
    fsType: ext4
  claimRef:
    namespace: default
    name: postgres-volume-claim
EOF


# Apply the Kubernetes configuration
kubectl apply -f kubernetes/storage-class.yaml && \
kubectl apply -f kubernetes/postgres-pv.yaml && \
kubectl apply -f kubernetes/postgres-claim.yaml

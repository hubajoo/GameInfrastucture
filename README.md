# GameInfrastructure

This repository contains the infrastructure setup for a Kubernetes cluster and related resources using Terraform and Kubernetes configuration files.

## Project Structure

```
    kubernetes/
        postgres-configmap.yaml
        postgres-pv.yaml
        postgres-pvc.yaml
        postgres-secret.yaml
        postgres-deployment.yaml
        postgres-service.yaml
        gameserver-configmap.yaml
        gameserver-service.yaml
        gameserver-deployment.yaml
        load-balancer.yaml
        ingress.yaml
    local-config/
        postgres-claim.yaml
    terraform_cluster/
        kubernetes/
            postgres-claim.yaml
            postgres-pv.yaml
            storage-service.yaml
        compute.tf
        eks-nodegroup.yaml
        main.tf
        network.tf
        providers.tf
        role.json
        terraform.tfstate
        terraform.tfstate.backup
    dependency-check.sh
    destroy.sh
    LICENSE
    README.md
    start.sh
    test.sh
```

## Dependencies

- **[Kubectl](https://kubernetes.io/docs/tasks/tools/install-kubectl/):** Required for managing Kubernetes clusters.
  
- **Bash:** Required for running shell scripts.
  ## EKS version 

  - **[Terraform](https://www.terraform.io/downloads.html):** Required for provisioning infrastructure.

  - **[AWS CLI](https://aws.amazon.com/cli/):** Required for managing AWS resources.

  ## Local version
  - **[Docker](https://docs.docker.com/get-docker/)**
  - **[Minikube](https://minikube.sigs.k8s.io/docs/start/)**

  - When using **[Minikube](https://minikube.sigs.k8s.io/docs/start/)** tunneling is recommended.

      ```sh
    minikube tunnel
    ```

 The start.sh, destroy.sh and test.sh scripts automatically verify dependencies, for manual verification use dependency-check.sh:

   ```sh
   ./dependency-check.sh
   ```

## Usage

  **Initialize Infrastructure:**

   ```sh
   ./start.sh
   ```
  This script will:

1. Verify dependencies.

2. Load environment variables from the `.env` file, or use default values.

3. Prompt the user if they want to use a dedicated cluster and if they are using minikube.
    - If the user selected dedicated cluster:

      - Apply the Terraform configuration to create/verify the EKS cluster.

      - Apply the Kubernetes manifests to create/update the necessary resources.

      - Update the kubeconfig for the cluster.

      - Output the load balancer's address.

    - If the user selected minikube:

      - Ask the user if the are using minikube.

      - Apply the Kubernetes manifests to create the necessary resources.

      - Output how they can access the server.
      
      - In minikube, the server can't get it's own address, so leader board funcionality is broken.


 **Verify Infrasctructure creation:**

   ```sh
   ./test.sh
   ```

  This script will:

  1. Verify dependencies.

  2. Verify that the necessiary Kubernetes configuration files are present.

  3. Check if the Kubernetes resources are successfully created.

 **Destroy Infrastructure:**

   ```sh
   ./destroy.sh
   ```
  This script will:

  1. Verify dependencies.

  2. Delete the Kubernetes resources.

  3. Destroy the EKS cluster using Terraform.



## Key Components

### Kubernetes Configuration

- **postgres-configmap.yaml:** ConfigMap for PostgreSQL configuration.
- **postgres-init-configmap.yaml:** ConfigMap for PostgreSQL initialization script.
- **postgres-pv.yaml:** PersistentVolume configuration for PostgreSQL.
- **postgres-claim.yaml** 
- **storage-class.yaml**
- **postgres-claim.yaml:** PersistentVolumeClaim configuration for PostgreSQL.
- **postgres-secret.yaml:** Secret configuration for PostgreSQL credentials.
- **postgres-deployment.yaml:** Deployment configuration for PostgreSQL.
- **postgres-service.yaml:** Service configuration for PostgreSQL.
- **gameserver-configmap.yaml:** ConfigMap for GameServer configuration.
- **gameserver-service.yaml:** Service configuration for GameServer.
- **gameserver-deployment.yaml:** Deployment configuration for GameServer.
- **load-balancer.yaml:** LoadBalancer service configuration for external access.
- **ingress.yaml:** Ingress configuration for routing external traffic.

### Terraform Configuration

- **compute.tf**: Terraform configuration for compute resources, including EKS cluster and node groups.
- **ebs-volumes.tf:** EBS volumes configuration for persistent storage.
- **main.tf**: Main Terraform configuration file that ties together all the resources.
- **network.tf**: Terraform configuration for network resources, including VPC, subnets, and security groups.
- **providers.tf**: Terraform configuration for provider settings, including AWS provider.
- **role.json**: JSON file defining IAM roles and policies for the EKS cluster.


### Scripts

- **start.sh**: Script to initialize the infrastructure by applying Terraform configurations and Kubernetes manifests.
- **destroy.sh**: Script to destroy the infrastructure by deleting Kubernetes resources and destroying the EKS cluster using Terraform.
- **test.sh**: Script to verify that the infrastructure is fully built and all Kubernetes resources are successfully created.
- **dependency-check.sh**: Script to check if all required dependencies (Terraform, kubectl, AWS CLI) are installed.
- **eks-setup.sh**: Script to apply Terraform templates, extract necessiary outputs and setup storage handling on the EKS cluster.


## License
This project is licensed under the MIT License. See the [LICENSE](LICENSE) file for details.
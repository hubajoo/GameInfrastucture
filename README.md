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
terraform_cluster/
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

## Key Components

### Kubernetes Configuration

- **postgres-configmap.yaml**: ConfigMap for PostgreSQL initialization script.
- **postgres-pv.yaml**: PersistentVolume configuration for PostgreSQL.
- **postgres-pvc.yaml**: PersistentVolumeClaim configuration for PostgreSQL.
- **postgres-secret.yaml**: Secret configuration for PostgreSQL credentials.
- **postgres-deployment.yaml**: Deployment configuration for PostgreSQL.
- **postgres-service.yaml**: Service configuration for PostgreSQL.
- **gameserver-configmap.yaml**: ConfigMap for GameServer configuration.
- **gameserver-service.yaml**: Service configuration for GameServer.
- **gameserver-deployment.yaml**: Deployment configuration for GameServer.
- **load-balancer.yaml**: LoadBalancer service configuration for external access.
- **ingress.yaml**: Ingress configuration for routing external traffic.


### Terraform Configuration

- **compute.tf**: Terraform configuration for compute resources, including EKS cluster and node groups.
- **main.tf**: Main Terraform configuration file that ties together all the resources.
- **network.tf**: Terraform configuration for network resources, including VPC, subnets, and security groups.
- **providers.tf**: Terraform configuration for provider settings, including AWS provider.
- **role.json**: JSON file defining IAM roles and policies for the EKS cluster.


### Scripts

- **start.sh**: Script to initialize the infrastructure by applying Terraform configurations and Kubernetes manifests.
- **destroy.sh**: Script to destroy the infrastructure by deleting Kubernetes resources and destroying the EKS cluster using Terraform.
- **test.sh**: Script to verify that the infrastructure is fully built and all Kubernetes resources are successfully created.
- **dependency-check.sh**: Script to check if all required dependencies (Terraform, kubectl, AWS CLI) are installed.



## Dependencies

- **AWS CLI:** Required for managing AWS resources.
- **kubectl:** Required for managing Kubernetes clusters.
- **Bash:** Required for running shell scripts.
- **Terraform:** Required for provisioning infrastructure.

 The start.sh, destroy.sh and test.sh scripts autmatically verify dependencies, for manual veryfication use dependeny-check.sh:

   ```sh
   ./dependeny-check.sh
   ```

## Usage

 **Initialize Infrastructure:**

   ```sh
   ./start.sh
   ```
This script will:
1. Verify dependencies.
2. Load environment variables from the `.env` file.
3. Apply the Terraform configuration to create the EKS cluster.
4. Update the kubeconfig for the EKS cluster.
5. Apply the Kubernetes manifests to create the necessary resources.
6. Output the address that you can use to access the application in your browser.

 **Verify Infrasctructure creation:**

   ```sh
   ./test.sh
   ```

This script will:
1. Veryfy dependencies.
2. Verify that the Kubernetes configuration files are present.
3. Check if the Kubernetes resources are successfully created.

 **Destroy Infrastructure:**

   ```sh
   ./destroy.sh
   ```
This script will:
1. Verify dependencies.
2. Delete the Kubernetes resources.
3. Destroy the EKS cluster using Terraform.

## License
This project is licensed under the MIT License. See the [LICENSE](LICENSE) file for details.
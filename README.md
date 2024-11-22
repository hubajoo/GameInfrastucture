# GameInfrastructure

This repository contains the infrastructure setup for a Kubernetes cluster and related resources using Terraform and Kubernetes configuration files.

## Project Structure

```
kubernetes/
    depl-service.yaml
    deployment.yaml
    ingress.yaml
    load-balancer.yaml
kubernetesInit.sh
LICENSE
README.md
terraform_cluster/
    .terraform/
        providers/
            registry.terraform.io/
                hashicorp/
                    aws/
                        5.72.1/
                            linux_amd64/
                                LICENSE.txt
                    tls/
                        4.0.6/
                            linux_amd64/
    .terraform.lock.hcl
    .terraform.tfstate.lock.info
    compute.tf
    eks-nodegroup.yaml
    main.tf
    network.tf
    providers.tf
    role.json
    terraform.tfstate
    terraform.tfstate.backup
```

## Key Components

### Kubernetes Configuration

- 

depl-service.yaml

: Service configuration for Kubernetes deployment.
- 

deployment.yaml

: Deployment configuration for Kubernetes.
- 

ingress.yaml

: Ingress configuration for Kubernetes.
- 

load-balancer.yaml

: Load balancer configuration for Kubernetes.

### Terraform Configuration

- 

compute.tf

: Terraform configuration for compute resources.
- 

main.tf

: Main Terraform configuration file.
- 

network.tf

: Terraform configuration for network resources.
- 

providers.tf

: Terraform providers configuration.
- 

role.json

: IAM role configuration for EKS.
- 

terraform.tfstate

: Terraform state file.
- 

terraform.tfstate.backup

: Backup of the Terraform state file.
- 

.terraform.lock.hcl

: Terraform lock file.
- 

.terraform.tfstate.lock.info

: Terraform state lock info.

### Scripts

- 

kubernetesInit.sh

: Script to initialize the Kubernetes cluster.

## Outputs

The Terraform state file (`terraform_cluster/terraform.tfstate`) includes the following output:

- `eks_cluster_autoscaler_arn`: ARN of the EKS cluster autoscaler role.

## Dependencies

- **AWS CLI:** Required for managing AWS resources.
- **kubectl:** Required for managing Kubernetes clusters.
- **Bash:** Required for running shell scripts.
- **Terraform:** Required for provisioning infrastructure.


## Usage

1. **Initialize Infrastructure:**

   ```sh
   ./init.sh
   ```
## License

2. **Destroy Infrastructure:**

   ```sh
   ./destroy.sh
   ```

The included bash scripts 

This project is licensed under the MIT License. See the 

LICENSE

 file for details.
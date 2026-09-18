# AWS platform infrastructure with Terraform

This project provisions a small AWS platform from Terraform:

- A VPC with public and private subnets, NAT gateway, and DNS support
- A public Network Load Balancer forwarding TCP/80 to an EC2 Nginx target
- An EKS cluster with one managed node group in the private subnets
- An Amazon Linux EC2 instance in a private subnet
- Jenkins and GitHub Actions workflows for format, validate, plan, and apply

## Prerequisites

Install Terraform 1.6+, AWS CLI, and configure AWS credentials with permission to create VPC, EC2, ELB, IAM, and EKS resources. EKS and NAT gateways can be expensive; destroy the stack when finished.

```bash
cd Terraform-Assignment1
cp terraform.tfvars.example terraform.tfvars
terraform init
terraform plan -var-file=terraform.tfvars
terraform apply -var-file=terraform.tfvars
terraform output
```

To remove the resources:

```bash
terraform destroy -var-file=terraform.tfvars
```

## GitHub Actions

Create an S3 bucket for Terraform state, then add these repository secrets: `AWS_ACCESS_KEY_ID`, `AWS_SECRET_ACCESS_KEY_ID`, and `TF_STATE_BUCKET`. The workflow uses the state key `terraform-assignment1/terraform.tfstate`. The AWS IAM user must be able to read and write that S3 object as well as manage the Terraform resources.

To destroy resources with the dedicated workflow, open **Actions** and select **Terraform Destroy**, then click **Run workflow**. Review the destroy plan, and approve the protected `terraform-destroy` environment before the destroy job runs.

If a local state file already contains the deployed resources, migrate it to the S3 backend from this directory before using GitHub Actions:

```bash
terraform init -migrate-state -backend-config="bucket=YOUR_STATE_BUCKET" -backend-config="key=terraform-assignment1/terraform.tfstate" -backend-config="region=us-east-1"
```

## Jenkins

Create Jenkins Secret Text credentials with IDs `AWS_ACCESS_KEY_ID`, `AWS_SECRET_ACCESS_KEY_ID`, and `TF_STATE_BUCKET`. The `Jenkinsfile` uses the shared S3 state key `terraform-assignment1/terraform.tfstate`. Configure a multibranch pipeline from this repository. Choose the `TERRAFORM_ACTION` build parameter to run `plan`, `apply`, or `destroy`. The `apply` and `destroy` actions are restricted to `main` and require manual approval.

## Production notes

This is a learning baseline. Before production, add an encrypted remote S3 backend with DynamoDB locking, restrict `ssh_cidr`, use separate state per environment, pin the module lock file, add EKS access entries/RBAC, and add private EKS endpoint controls and CloudWatch logging.

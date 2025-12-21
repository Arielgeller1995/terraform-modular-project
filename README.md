# Free-tier friendly Terraform layout (example)

This repo is an example of a **working Terraform folder structure** split into:

- `modules/`: reusable building blocks (VPC, IAM, optional EKS, etc.)
- `environments/`: environment + region roots (`dev/eu-north-1/...`) that compose modules

The defaults are intentionally **free-tier safe**:

- **No NAT Gateway by default** (NAT is billable)
- **No EKS by default** (EKS control plane is billable)
- Optional “paid” services (EKS/WAF/Global Accelerator/managed Prometheus) are behind `enabled` flags

## Prereqs

- Terraform `~> 1.9`
- AWS credentials available in your shell (e.g. `AWS_PROFILE`, `AWS_ACCESS_KEY_ID`, etc.)

## Quickstart (dev / eu-north-1)

Apply in this order (so remote state references resolve):

1) Networking

```bash
cd environments/dev/eu-north-1/networking
terraform init
terraform apply
```

2) IAM

```bash
cd ../iam
terraform init
terraform apply
```

3) Security (security groups + optional modules disabled)

```bash
cd ../security
terraform init
terraform apply
```

4) Kubernetes (optional / disabled by default)

```bash
cd ../kubernetes
terraform init
terraform apply
```

To intentionally enable EKS (billable), set:

```bash
terraform apply -var='enable_eks=true'
```

## State model

Each component keeps its own state file (local backend):

- `environments/dev/eu-north-1/networking/terraform.tfstate`
- `environments/dev/eu-north-1/iam/terraform.tfstate`
- `environments/dev/eu-north-1/security/terraform.tfstate`
- `environments/dev/eu-north-1/kubernetes/terraform.tfstate`

Other components reference outputs via `terraform_remote_state` using the local state file paths.

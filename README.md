# Terraform modular project

This repository contains a modular Terraform layout with environment-level root modules under `environments/` and reusable modules under `modules/`.

## Structure

- `environments/dev/eu-north-1/*`: dev environment stacks (networking, kubernetes, iam, security)
- `modules/*`: reusable Terraform modules

## Usage (example)

From a given stack directory (e.g. `environments/dev/eu-north-1/networking`):

1. `terraform init`
2. `terraform fmt -recursive`
3. `terraform validate`
4. `terraform plan`

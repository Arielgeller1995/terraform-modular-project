terraform {
  required_version = "~> 1.9.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 6.0.0"
    }
  }
}

provider "aws" {
  region = "eu-north-1"
}


module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "21.10.1"

  name               = var.cluster_name
  kubernetes_version = var.cluster_version
  create             = true

  # ===== Networking =====
  vpc_id     = data.terraform_remote_state.networking.outputs.vpc_id
  subnet_ids = data.terraform_remote_state.networking.outputs.private_subnets

  # Make endpoint access explicit: nodes in private subnets can reach the API
  # via VPC routing (private access) or NAT (public access).
  cluster_endpoint_private_access = true
  cluster_endpoint_public_access  = true

  # Dev default. Tighten this to your IP/CIDR in real usage.
  cluster_endpoint_public_access_cidrs = ["0.0.0.0/0"]

  # ===== Node Groups =====
  eks_managed_node_groups = {
    default = {
      name = "default-ng"

      min_size     = var.min_size
      desired_size = var.desired_size
      max_size     = var.max_size

      instance_types = var.instance_types
      disk_size      = 20
      capacity_type  = "ON_DEMAND"

      # For newer Kubernetes versions, Amazon Linux 2023 is the safest default.
      # If you know AL2 is supported for your exact K8s version/region, you can switch back.
      ami_type = var.ami_type
    }
  }

  # ===== IAM / IRSA =====
  enable_irsa = true

  # Helps ensure you can administer the cluster after creation.
  enable_cluster_creator_admin_permissions = true

  # ===== Tags =====
  tags = {
    Environment = "dev"
    Project     = "terraform-modular"
  }
}

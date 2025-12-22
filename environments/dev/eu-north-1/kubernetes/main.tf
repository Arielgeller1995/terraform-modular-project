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
  kubernetes_version = "1.32"
  create             = true

  # ===== Networking =====
  vpc_id     = data.terraform_remote_state.networking.outputs.vpc_id
  subnet_ids = data.terraform_remote_state.networking.outputs.private_subnets

  # ===== Node Groups =====
  eks_managed_node_groups = {
    default = {
      name            = "default-ng"
      use_name_prefix = false
      min_size        = 1
      desired_size    = 1
      max_size        = 2

      instance_types = var.instance_types
      disk_size      = 20
      capacity_type  = "ON_DEMAND"
    }
  }

  # ===== IAM / IRSA =====
  enable_irsa = true
  enable_cluster_creator_admin_permissions = true

  # ===== Addons =====
  cluster_addons = {
    coredns = {
      most_recent = true
    }
    kube-proxy = {
      most_recent = true
    }
    vpc-cni = {
      most_recent = true
    }
  }

  # ===== Tags =====
  tags = {
    Environment = "dev"
    Project     = "terraform-modular"
  }
}

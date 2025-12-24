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

  # Control plane access
  endpoint_public_access  = true
  endpoint_private_access = false

  # ===== Node Groups =====
  eks_managed_node_groups = {
    default = {
      name            = "default-ng"
      use_name_prefix = false
      # Explicitly specify subnets for node group
      subnet_ids = data.terraform_remote_state.networking.outputs.private_subnets
      min_size     = var.min_size
      desired_size = var.desired_size
      max_size     = var.max_size

      instance_types             = var.instance_types
      ami_type                   = var.ami_type
      disk_size                  = 20
      capacity_type              = "ON_DEMAND"
      iam_role_attach_cni_policy = true
      
      # Tags for node identification
      tags = {
        Name        = "${var.cluster_name}-default-node"
        Environment = "dev"
      }
    }
  }

  # ===== IAM / IRSA =====
  enable_irsa = true

  # ===== Addons (required for working nodes) =====
  # cluster_addons was removed because this module version does not accept that attribute here;
  # manage Amazon VPC CNI, kube-proxy and CoreDNS via separate Helm/kubernetes resources or use
  # the module's currently supported inputs for addons if available.
  
  # ===== Tags =====
  tags = {
    Environment = "dev"
    Project     = "terraform-modular"
  }
}

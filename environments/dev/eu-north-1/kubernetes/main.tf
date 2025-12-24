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
  vpc_id     = local.vpc_id
  subnet_ids = local.private_subnets

  # Control plane access
  endpoint_public_access  = true
  endpoint_private_access = false

  # ===== KMS =====
  # Allow module to manage KMS key (will handle existing resources via import)
  create_kms_key = true

  # ===== CloudWatch Logging =====
  # Enable cluster logging
  enable_cluster_creator_admin_permissions = true
  cluster_enabled_log_types                 = ["api", "audit", "authenticator", "controllerManager", "scheduler"]

  # ===== Node Groups =====
  # Temporarily disabled - will be enabled after cluster is created/imported
  # The node group module requires the cluster to exist in state first
  eks_managed_node_groups = {}

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

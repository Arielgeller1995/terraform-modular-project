module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "21.10.1"

  name               = var.cluster_name
  kubernetes_version = var.cluster_version

  # ===== Networking =====
  vpc_id     = local.vpc_id
  subnet_ids = local.private_subnets

  # Control plane access
  endpoint_public_access  = true
  endpoint_private_access = false

  # ===== Node Groups =====
  eks_managed_node_groups = {
    default = {
      name            = "default-ng"
      use_name_prefix = false
      # Explicitly specify subnets for node group
      subnet_ids   = local.private_subnets
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

  # ===== EKS managed addons =====
  addons = {
    coredns    = { most_recent = true }
    kube-proxy = { most_recent = true }
    vpc-cni    = { most_recent = true }
  }

  # ===== IAM / IRSA =====
  enable_irsa = true
  # ===== Tags =====
  tags = {
    Environment = "dev"
    Project     = "terraform-modular"
  }
}

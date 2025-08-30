# eks.tf - EKS Cluster Module and Worker Node Definitions

data "aws_ami" "eks_worker_ami" {
  most_recent = true
  owners      = ["602401143452"]
  filter {
    name   = "name"
    values = ["amazon-eks-node-*-${var.cluster_version}-v*"]
  }
  filter {
    name   = "architecture"
    values = ["x86_64"]
  }
}

module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 20.0"

  cluster_name    = local.name
  cluster_version = var.cluster_version

  vpc_id     = module.vpc.vpc_id
  subnet_ids = module.vpc.private_subnets

  enable_irsa = true

  cluster_endpoint_private_access = false
  cluster_endpoint_public_access  = true

  manage_aws_auth_configmap = true
  aws_auth_users = [
    {
      userarn  = "arn:aws:iam::045973518776:user/AdministratorAccess" 
      username = "admin-user"
      groups   = ["system:masters"]
    },
  ]

  eks_managed_node_groups = {
    default = {
      min_size     = var.min_size
      max_size     = var.max_size
      desired_size = var.desired_size

      instance_types = var.instance_types
      ami_type       = var.ami_type
      key_name       = "my-webapp-key"
      
      vpc_security_group_ids = [aws_security_group.webapp_sg.id]
    }
  }

  tags = {
    Environment = "Dev"
    Project     = "EKS-Demo"
  }
}

# modules/networking/vpc/main.tf

locals {
  # EKS (and AWS load balancers) rely on these tags for subnet discovery.
  # When cluster_name is unset, we fall back to just the role tags.
  cluster_subnet_tags = var.cluster_name == null ? {} : {
    "kubernetes.io/cluster/${var.cluster_name}" = "shared"
  }
}

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 5.0"

  name = var.name
  cidr = var.vpc_cidr # the entire VPC

  azs             = var.azs
  private_subnets = [for k, _ in var.azs : cidrsubnet(var.vpc_cidr, 4, k)]
  public_subnets  = [for k, _ in var.azs : cidrsubnet(var.vpc_cidr, 8, k + 48)]

  enable_nat_gateway   = var.enable_nat_gateway
  single_nat_gateway   = var.single_nat_gateway
  enable_dns_hostnames = true
  enable_dns_support   = true

  public_subnet_tags = merge(
    {
      "kubernetes.io/role/elb" = 1
    },
    local.cluster_subnet_tags,
  )

  private_subnet_tags = merge(
    {
      "kubernetes.io/role/internal-elb" = 1
    },
    local.cluster_subnet_tags,
  )

  tags = var.tags
}

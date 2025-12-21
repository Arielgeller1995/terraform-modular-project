module "vpc" {
  source             = "../../../../modules/networking/vpc"
  name               = local.name
  vpc_cidr           = local.vpc_cidr
  azs                = local.azs
  # NAT Gateways are billable; keep them off by default for free-tier safety.
  enable_nat_gateway = false
  single_nat_gateway = true

  # If you later enable EKS, these subnet tags help discovery.
  cluster_name = local.name
  tags               = local.tags
}

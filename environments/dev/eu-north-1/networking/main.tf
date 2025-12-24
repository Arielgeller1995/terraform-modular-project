module "vpc" {
  source             = "../../../../modules/networking/vpc"
  name               = local.name
  vpc_cidr           = local.vpc_cidr
  azs                = local.azs
  enable_nat_gateway = true
  single_nat_gateway = true
  tags               = local.tags
  cluster_name       = var.cluster_name

}

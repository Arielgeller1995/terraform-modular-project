locals {
  name     = var.cluster_name
  region   = var.aws_region
  azs      = data.aws_availability_zones.available.names
  vpc_cidr = "10.0.0.0/16"
  tags = { Environment = "dev", Project = "eks" }
}

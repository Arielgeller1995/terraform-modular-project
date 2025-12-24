locals {
  name     = var.cluster_name
  azs      = slice(data.aws_availability_zones.available.names, 0, 2)  # Use only first 2 AZs
  vpc_cidr = "10.0.0.0/16"
  tags     = { Environment = "dev", Project = "eks" }
}

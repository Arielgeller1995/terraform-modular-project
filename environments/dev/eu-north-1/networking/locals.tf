locals {
  # Keep this environment's naming consistent across components.
  name = var.name

  # Use 2 AZs by default to keep the demo simple and predictable.
  # (More subnets are free, but this reduces noise.)
  azs = slice(data.aws_availability_zones.available.names, 0, 2)
  vpc_cidr = "10.0.0.0/16"

  tags = {
    Environment = "dev"
    Project     = "free-tier-terraform-structure"
  }
}

locals {
  name     = "dev-vpc"
  vpc_cidr = "10.0.0.0/16"

  azs = [
    "eu-north-1a",
    "eu-north-1b",
    "eu-north-1c",
  ]

  tags = {
    Environment = "dev"
    Project     = "terraform-modular-learning"
  }
}

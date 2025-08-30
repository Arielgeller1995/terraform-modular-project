# vpc.tf - VPC Module for EKS Networking

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 5.0"

  name = local.name
  cidr = local.vpc_cidr #the entire VPC

  azs             = local.azs #availability zones
  private_subnets = [for k, v in local.azs : cidrsubnet(local.vpc_cidr, 4, k)] #LOOP-FOR
  public_subnets  = [for k, v in local.azs : cidrsubnet(local.vpc_cidr, 8, k + 48)]

  enable_nat_gateway = true
  single_nat_gateway = true
  enable_dns_hostnames = true
  enable_dns_support = true

  public_subnet_tags = {
    "kubernetes.io/role/elb" = 1
  }

  private_subnet_tags = {
    "kubernetes.io/role/internal-elb" = 1
  }
 
  tags = local.tags
}

data "aws_availability_zones" "available" {
  state = "available"
}
# security_groups.tf - Security Groups for Worker Nodes

resource "aws_security_group" "webapp_sg" {
  name        = "terraform-webapp-sg"
  description = "Allow SSH and HTTP traffic to EKS nodes"
  vpc_id      = module.vpc.vpc_id

  ingress {
    from_port   = 22 #SSH
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] #open for the world
  }

  ingress {
    from_port   = 80 #HTTP
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] #open for the world
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1" #all protocols
    cidr_blocks = ["0.0.0.0/0"]
  }
                        
  tags = { #the tags are to identify
    Name = "terraform-webapp-sg"
  }
}

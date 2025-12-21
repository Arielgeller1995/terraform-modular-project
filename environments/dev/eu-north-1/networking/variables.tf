
variable "aws_region" {
  type    = string
  default = "eu-north-1"
}

variable "cluster_name" {
  type    = string
  # Keep this aligned with the EKS environment's cluster_name; it's also used
  # to tag subnets for EKS discovery (kubernetes.io/cluster/<name>).
  default = "dev-eks-cluster"
}

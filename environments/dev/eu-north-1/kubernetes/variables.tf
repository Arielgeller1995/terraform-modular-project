variable "cluster_name" {
  description = "EKS cluster name"
  type        = string
  default     = "dev-eks-cluster"
}

variable "cluster_version" {
  description = "EKS cluster version"
  type        = string
  default     = "1.30"
}

variable "ami_type" {
  description = "Node group AMI type"
  type        = string
  default     = "AL2_x86_64"
}

variable "instance_types" {
  description = "Node group instance types"
  type        = list(string)
  default     = ["t3.small"]
}

variable "min_size" {
  description = "Min nodes in node group"
  type        = number
  default     = 1
}

variable "desired_size" {
  description = "Desired nodes in node group"
  type        = number
  default     = 2
}

variable "max_size" {
  description = "Max nodes in node group"
  type        = number
  default     = 3
}

variable "cluster_name" {
  description = "EKS cluster name"
  type        = string
  default     = "dev-eks-cluster"
}

variable "cluster_version" {
  description = "EKS cluster version"
  type        = string
  default     = "1.32"
}

variable "ami_type" {
  description = "Node group AMI type"
  type        = string
  # AL2023 is the recommended default for new clusters and newer K8s versions.
  # Valid values depend on AWS/EKS; common x86_64 choice:
  # - AL2023_x86_64_STANDARD
  default = "AL2023_x86_64_STANDARD"
}

variable "instance_types" {
  description = "Node group instance types"
  type        = list(string)
  default     = ["t3.medium"]
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

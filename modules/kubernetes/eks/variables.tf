variable "ami_type" {
  type        = string
  description = "The type of AMI to use for the EKS node group"
}

variable "cluster_version" {
  type        = string
  description = "The Kubernetes version for the EKS cluster"
}

variable "desired_size" {
  type        = number
  description = "Desired number of worker nodes"
}

variable "instance_types" {
  type        = list(string)
  description = "List of EC2 instance types for the EKS node group"
}

variable "max_size" {
  type        = number
  description = "Maximum number of worker nodes"
}

variable "min_size" {
  type        = number
  description = "Minimum number of worker nodes"
}


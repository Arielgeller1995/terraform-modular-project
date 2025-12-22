variable "name" {
  type        = string
  description = "Name prefix for the VPC and related resources"
}

variable "vpc_cidr" {
  type        = string
  description = "CIDR block for the VPC"
}

variable "azs" {
  type        = list(string)
  description = "Availability zones to spread subnets across (e.g., [\"eu-north-1a\", \"eu-north-1b\", \"eu-north-1c\"])"
}

variable "enable_nat_gateway" {
  type        = bool
  description = "Whether to create NAT Gateway(s)"
  default     = false
}

variable "single_nat_gateway" {
  type        = bool
  description = "Whether to use a single NAT Gateway across all AZs"
  default     = true
}

variable "tags" {
  type        = map(string)
  description = "Common tags to apply to resources"
  default     = {}
}
variable "cluster_name" {
  type        = string
  description = "EKS cluster name used for subnet discovery tags (kubernetes.io/cluster/<name>)"
  default     = null
}


# Security Group (webapp nodes) parameters
variable "webapp_sg_name" {
  type        = string
  description = "Name for the webapp Security Group"
  default     = "terraform-webapp-sg"
}

variable "webapp_sg_description" {
  type        = string
  description = "Description for the webapp Security Group"
  default     = "Allow SSH, HTTP, and HTTPS to EKS nodes"
}

variable "ssh_ingress_cidr_blocks" {
  type        = list(string)
  description = "CIDR blocks allowed for SSH ingress"
  default     = ["0.0.0.0/0"]
}

variable "http_ingress_cidr_blocks" {
  type        = list(string)
  description = "CIDR blocks allowed for HTTP ingress"
  default     = ["0.0.0.0/0"]
}

variable "https_ingress_cidr_blocks" {
  type        = list(string)
  description = "CIDR blocks allowed for HTTPS ingress"
  default     = ["0.0.0.0/0"]
}



variable "aws_region" {
  type    = string
  default = "eu-north-1"
}

variable "name" {
  description = "Name prefix used for networking resources."
  type        = string
  default     = "dev-free-tier"
}

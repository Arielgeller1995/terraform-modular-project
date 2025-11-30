output "vpc_id" {
  description = "The ID of the VPC"
  value       = module.vpc.vpc_id
}

#output "private_subnet_ids" {
#  description = "Private subnet IDs"
#  value       = module.vpc.private_subnets
#}

#output "webapp_sg_id" {
#  description = "Security group ID for webapp"
#  value       = aws_security_group.webapp_sg.id
#}
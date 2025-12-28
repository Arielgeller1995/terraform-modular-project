# VPC core
output "vpc_id" {
  description = "The ID of the VPC"
  value       = module.vpc.vpc_id
}

output "vpc_arn" {
  description = "The ARN of the VPC"
  value       = module.vpc.vpc_arn
}

output "vpc_cidr_block" {
  description = "The CIDR block of the VPC"
  value       = module.vpc.vpc_cidr_block
}

# Subnets
output "public_subnet_ids" {
  description = "IDs of the public subnets"
  value       = module.vpc.public_subnets
}

output "public_subnets" {
  description = "IDs of the public subnets (alias for compatibility)"
  value       = module.vpc.public_subnets
}

output "private_subnet_ids" {
  description = "IDs of the private subnets"
  value       = module.vpc.private_subnets
}
output "private_subnets" {
  description = "IDs of the private subnets (alias for compatibility)"
  value       = module.vpc.private_subnets
}


# Route tables & gateways
output "public_route_table_ids" {
  description = "Public route table IDs"
  value       = module.vpc.public_route_table_ids
}

output "private_route_table_ids" {
  description = "Private route table IDs"
  value       = module.vpc.private_route_table_ids
}

output "internet_gateway_id" {
  description = "Internet Gateway ID"
  value       = module.vpc.igw_id
}

output "nat_gateway_ids" {
  description = "NAT Gateway IDs"
  value       = module.vpc.natgw_ids
}

# Security Group (webapp)
#output "webapp_sg_id" {
#description = "Security Group ID for the webapp nodes"
# value       = aws_security_group.webapp_sg.id
#}

#output "webapp_sg_arn" {
#description = "Security Group ARN for the webapp nodes"
# value       = aws_security_group.webapp_sg.arn
#}

#output "webapp_sg_name" {
#description = "Security Group name for the webapp nodes"
# value       = aws_security_group.webapp_sg.name
#}


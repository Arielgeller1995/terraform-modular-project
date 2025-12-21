output "vpc_id" {
  description = "VPC id"
  value       = module.vpc.vpc_id
}

output "private_subnets" {
  description = "List of private subnet IDs"
  value       = try(module.vpc.private_subnet_ids, try(module.vpc.private_subnets, []))
}

output "public_subnets" {
  description = "List of public subnet IDs"
  value       = try(module.vpc.public_subnet_ids, try(module.vpc.public_subnets, []))
}

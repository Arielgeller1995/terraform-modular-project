# environments/dev/eu-north-1/networking/outputs.tf
output "vpc_id" {
  description = "VPC id"
  value       = try(module.vpc.vpc_id, module.vpc.id, null)
}

output "private_subnets" {
  description = "List of private subnets IDs (best-effort)"
  value = try(
    module.vpc.private_subnets,
    module.vpc.private_subnet_ids,
    module.vpc.private_subnet_id,
    module.vpc.subnet_ids,
    module.vpc.subnets,
    null
  )
}

output "public_subnets" {
  description = "List of public subnets IDs (best-effort)"
  value = try(
    module.vpc.public_subnets,
    module.vpc.public_subnet_ids,
    module.vpc.public_subnet_id,
    module.vpc.public_subnets_ids,
    null
  )
}

# אופציונלי — security group / nat gateway ids, ישאירו null אם לא קיימים במודול
output "webapp_sg_id" {
  description = "Webapp security group id (best-effort)"
  value = try(
    module.vpc.webapp_sg_id,
    module.vpc.webapp_security_group_id,
    module.vpc.webapp_security_group,
    module.vpc.security_group_id,
    null
  )
}

output "nat_gateway_ids" {
  description = "NAT gateway ids (best-effort)"
  value = try(
    module.vpc.nat_gateway_ids,
    module.vpc.nat_gateway_id,
    null
  )
}

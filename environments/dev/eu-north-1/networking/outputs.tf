output "vpc_id"             { 
value = module.vpc.vpc_id 
}

output "private_subnet_ids"{
value = module.vpc.private_subnets
}

output "webapp_sg_id" { 
value = aws_security_group.webapp_sg.id 
}

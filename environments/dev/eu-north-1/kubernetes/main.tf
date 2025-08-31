module "eks" {
  source = "../../../../../../modules/kubernetes/eks"

  cluster_version    = var.cluster_version
  ami_type           = var.ami_type
  instance_types     = var.instance_types
  min_size           = var.min_size
  desired_size       = var.desired_size
  max_size           = var.max_size

  vpc_id             = data.terraform_remote_state.networking.outputs.vpc_id
  private_subnet_ids = data.terraform_remote_state.networking.outputs.private_subnet_ids
  security_group_ids = [data.terraform_remote_state.networking.outputs.webapp_sg_id]
}

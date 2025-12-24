locals {
  # TODO: Switch to remote state outputs once they're available in the state file
  # Currently using hardcoded values because remote state outputs object is empty
  # Once networking outputs are properly saved, uncomment the lines below:
  # vpc_id          = data.terraform_remote_state.networking.outputs.vpc_id
  # private_subnets = data.terraform_remote_state.networking.outputs.private_subnets
  
  vpc_id          = "vpc-0693f358aeb574e75"
  private_subnets = ["subnet-0d917e8e335a03aba", "subnet-05c5994d46afc3d58"]
}

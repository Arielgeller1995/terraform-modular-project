terraform {
  # Free-tier friendly default: local state.
  #
  # If you want remote state later, switch this to an `s3` backend
  # and provision the bucket + DynamoDB lock table separately.
  backend "local" {
    path = "terraform.tfstate"
  }
}

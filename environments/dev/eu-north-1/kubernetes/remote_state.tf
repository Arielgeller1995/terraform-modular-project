data "terraform_remote_state" "networking" {
  backend = "s3"

  config = {
    bucket         = "ariel-terraform-state"
    key            = "dev/eu-north-1/networking/terraform.tfstate"
    region         = "eu-north-1"
    dynamodb_table = "terraform-locks"
    encrypt        = true
  }
}
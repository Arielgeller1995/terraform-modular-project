terraform {
  backend "s3" {
    bucket         = "ariel-terraform-state"
    key            = "dev/eu-north-1/kubernetes/terraform.tfstate"
    region         = "eu-north-1"
    dynamodb_table = "terraform-locks"
    encrypt        = true
  }
}
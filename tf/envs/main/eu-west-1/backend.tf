terraform {
  backend "s3" {
    bucket         = "devops-terraform-states"
    key            = "123456789876/eu-west-1/terraform.tfstate"
    region         = "eu-west-1"
    dynamodb_table = "terraform_locks"
  }
}
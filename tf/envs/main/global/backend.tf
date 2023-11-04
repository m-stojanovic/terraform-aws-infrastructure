terraform {
  backend "s3" {
    bucket         = "devops-terraform-states"
    key            = "global/global.tfstate"
    region         = "eu-west-1"
    dynamodb_table = "terraform_locks"
  }
}
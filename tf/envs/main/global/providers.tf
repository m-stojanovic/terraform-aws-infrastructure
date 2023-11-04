provider "aws" {
  region = "eu-west-1"
  assume_role {
    role_arn = "arn:aws:iam::${var.aws_account_id}:role/JenkinsDeployment"
  }
}

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "= 4.30.0"
    }
  }
}

terraform {
  required_version = ">= 0.12.1"

  required_providers {
    null = "~> 2.1"
  }
}

provider "aws" {
  region  = var.aws_region
  version = "~> 2.25" 

  assume_role {
    role_arn = var.aws_assume_role_arn
  }
}

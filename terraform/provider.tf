# Configure the AWS Provider
provider "aws" {
  region = var.aws_region
}

# Terraform block for requirements
terraform {
  required_version = ">= 1.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

# Configure Terraform to store the state file remotely in S3 bucket

terraform {
  backend "s3" {
    bucket  = "ofek-status-page-terraform-state"
    key     = "status-page/terraform.tfstate"
    region  = "us-east-1"
    encrypt = true
  }
}
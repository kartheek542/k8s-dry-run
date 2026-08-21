terraform {
  required_version = ">= 1.5.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.52.0"
    }
  }

  backend "s3" {
    bucket         = "k8s-dry-run-tf-state-303417979872-ap-south-1-an"
    key            = "docker-host/terraform.tfstate"
    region         = "ap-south-1"
    encrypt        = true
    dynamodb_table = "k8s-dry-run-tf-state-lock"
  }
}

provider "aws" {
  region = var.aws_region

  default_tags {
    tags = {
      Environment = "${terraform.workspace}"
      Project     = "k8s-dry-run"
      ManagedBy   = "Kar-Terraform"
    }
  }
}
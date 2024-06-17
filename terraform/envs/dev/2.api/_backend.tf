###################
# General Initialization
###################
terraform {
  required_version = ">= 0.13"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 3.37"
    }
    template = "~> 2.0"
    sops = {
      source  = "carlpett/sops"
      version = "~>0.7.1"
    }
  }
  backend "s3" {
    profile = "ecs-demo-dev"
    bucket  = "iac-terraform-demo1"
    key     = "api/terraform.dev.tfstate"
    region  = "ap-northeast-1"
  }
}

# Configure the AWS Provider
provider "aws" {
  profile = var.pipeline == true ? null : "ecs-demo-dev"
  region  = var.region
  default_tags {
    tags = {
      Project     = var.project
      Environment = var.env
    }
  }
}
# data "aws_caller_identity" "current" {}

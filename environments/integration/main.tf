terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "6.0.0-beta1"
    }
  }
}

provider "aws" {
  region = var.region
}

module "aws_backend" {
  source            = "./../../modules/aws_backend"
  domain_name_api   = var.domain_name_api
  backend_name_prefix = var.backend_name_prefix
}

module "aws_frontend" {
  source            = "./../../modules/aws_frontend"
  s3_name           = var.s3_name
  domain_name_app   = var.domain_name_app
}
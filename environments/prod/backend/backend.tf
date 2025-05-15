terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "6.0.0-beta1"
    }
  }
}

provider "aws" {
  region = "us-east-1"
}

module "aws_backend" {
  source            = "./../../modules/aws_backend"
  domain_name_api   = "api.yuriypikh.site"
  backend_name_prefix = "prod-api"
  env_name = "prod"
}
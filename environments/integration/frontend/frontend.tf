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

module "aws_frontend" {
  source            = "./../../modules/aws_frontend"
  s3_name           = "app.integration.yuriypikh.site"
  domain_name_app   = "app.integration.yuriypikh.site"
}
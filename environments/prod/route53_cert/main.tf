terraform {
  backend "s3" {
    bucket  = "my-tf-state-prod-45"
    key     = "prod/route53_cert/terraform.tfstate"
    region  = "us-east-1"
    encrypt = true
  }
}

provider "aws" {
  region = "us-east-1"
}


module "route53_cert_app" {
  source          = "../../../modules/route53_cert"
  env             = "prod"
  domain_name_api = "yuriypikh.site"
}

module "route53_cert_api" {
  source          = "../../../modules/route53_cert"
  env             = "prod"
  domain_name_api = "api.yuriypikh.site"
}


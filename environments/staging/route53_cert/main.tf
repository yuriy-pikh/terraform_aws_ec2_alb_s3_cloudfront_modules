terraform {
  backend "s3" {
    bucket         = "my-tf-state-prod-45"
    key            = "staging/route53_cert/terraform.tfstate"
    region         = "us-east-1"
    encrypt        = true
  }
}

provider "aws" {
  region  = "us-east-1"
}

module "route53_cert_api" {
  source                  = "../../../modules/route53_cert"
  env                     = "staging"
  domain_name_api         = "api.staging.yuriypikh.site"
}

module "route53_cert_app" {
  source                  = "../../../modules/route53_cert"
  env                     = "staging"
  domain_name_api         = "app.staging.yuriypikh.site"
}
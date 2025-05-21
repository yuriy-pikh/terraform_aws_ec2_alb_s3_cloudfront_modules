terraform {
  backend "s3" {
    bucket         = "my-tf-state-prod-45"
    key            = "integration/route53_cert/terraform.tfstate"
    region         = "us-east-1"
    encrypt        = true
  }
}

provider "aws" {
  region  = "us-east-1"
}

module "route53_cert_api" {
  source                  = "../../../modules/route53_cert"
  env                     = "integration"
  domain_name_api         = "api.integration.yuriypikh.site"
}

module "route53_cert_app" {
  source                  = "../../../modules/route53_cert"
  env                     = "integration"
  domain_name_api         = "app.integration.yuriypikh.site"
}
terraform {
  backend "s3" {
    bucket         = "my-tf-state-prod-45"
    key            = "prod/frontend/terraform.tfstate"
    region         = "us-east-1"
    encrypt        = true
  }
}

data "terraform_remote_state" "network" {
  backend = "s3"
  config = {
    bucket = "my-tf-state-prod-45"
    key    = "prod/network/terraform.tfstate"
    region = "us-east-1"
  }
}

data "terraform_remote_state" "route53_cert_app" {
  backend = "s3"
  config = {
    bucket = "my-tf-state-prod-45"
    key    = "prod/route53_cert/terraform.tfstate"
    region = "us-east-1"
  }
}

provider "aws" {
  region  = "us-east-1"
}

module "frontend" {
  source = "../../../modules/frontend"
  s3_name           = "yuriypikh.site"
  domain_name_app   = "yuriypikh.site"
  env               = "prod"
  certificate_arn = data.terraform_remote_state.route53_cert_app.outputs.certificate_arn_route53_cert_app
  route53_zone_id = data.terraform_remote_state.route53_cert_app.outputs.zone_id_route53_cert_app

}


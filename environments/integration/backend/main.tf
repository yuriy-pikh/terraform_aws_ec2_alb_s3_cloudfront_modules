terraform {
  backend "s3" {
    bucket         = "my-tf-state-prod-45"
    key            = "integration/backend/terraform.tfstate"
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

data "terraform_remote_state" "route53_cert_api" {
  backend = "s3"
  config = {
    bucket = "my-tf-state-prod-45"
    key    = "integration/route53_cert/terraform.tfstate"
    region = "us-east-1"
  }
}

provider "aws" {
  region = "us-east-1"
}

module "backend" {
  source                  = "../../../modules/backend"
  domain_name_api         = "api.integration.yuriypikh.site"
  env                     = "integration"
  vpc_id              = data.terraform_remote_state.network.outputs.vpc_id
  public_subnet_ids   = data.terraform_remote_state.network.outputs.public_subnet_ids
  private_subnet_ids  = data.terraform_remote_state.network.outputs.private_subnet_ids
  certificate_arn     = data.terraform_remote_state.route53_cert_api.outputs.certificate_arn
  route53_zone_id     = data.terraform_remote_state.route53_cert_api.outputs.zone_id
}



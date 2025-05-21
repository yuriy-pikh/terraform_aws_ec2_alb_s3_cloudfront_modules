terraform {
  backend "s3" {
    bucket         = "my-tf-state-prod-45"
    key            = "prod/network/terraform.tfstate"
    region         = "us-east-1"
    encrypt        = true
  }
}

provider "aws" {
  region  = "us-east-1"
}

module "network" {
  source = "../../../modules/network"
  env    = "prod"
}

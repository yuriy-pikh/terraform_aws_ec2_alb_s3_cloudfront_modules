variable "region" {
  type    = string
  default = "us-east-1"
  description = "AWS region for the deployment."
}

variable "domain_name_api" {
  type    = string
  default = "api.staging.yuriypikh.site"
  description = "Domain name for the API."
}

variable "domain_name_app" {
  type    = string
  default = "app.staging.yuriypikh.site"
  description = "Domain name for the application frontend."
}

variable "s3_name" {
  type    = string
  default = "app.staging.yuriypikh.site"
  description = "Name of the S3 bucket for the frontend static assets."
}

variable "backend_name_prefix" {
  type    = string
  default = "backend"
  description = "Prefix for the names of resources created by the aws_backend module."
}

variable "frontend_name_prefix" {
  type    = string
  default = "frontend"
  description = "Prefix for the names of resources created by the aws_frontend module."
}
variable "domain_name_app" {
  type        = string
  description = "The domain name for the application frontend (e.g., app.example.com)."
}

variable "s3_name" {
  type        = string
  description = "The globally unique name for the S3 bucket hosting the frontend assets."
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
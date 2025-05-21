variable "domain_name_app" {
  type        = string
  description = "The domain name for the application frontend (e.g., app.example.com)."
}

variable "s3_name" {
  type        = string
  description = "The globally unique name for the S3 bucket hosting the frontend assets."
}

variable "env" {
  type = string
  validation {
    condition     = can(regex("^[a-z0-9]{2,10}$", var.env))
    error_message = "env must be 2-10 lowercase alphanumeric characters"
  }
}

variable "certificate_arn" {
  description = "The ARN of the ACM certificate for the CloudFront distribution."
  type        = string
}

variable "route53_zone_id" {
  description = "The Route 53 Hosted Zone ID where the CloudFront alias record will be created."
  type        = string
}
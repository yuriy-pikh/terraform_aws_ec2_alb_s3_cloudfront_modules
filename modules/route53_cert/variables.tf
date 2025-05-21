variable "domain_name_api" {
  type        = string
  description = "The domain name for the API (e.g., api.example.com)."
}

variable "env" {
  type = string
  validation {
    condition     = can(regex("^[a-z0-9]{2,10}$", var.env))
    error_message = "env must be 2-10 lowercase alphanumeric characters"
  }
}


variable "vpc_cidr" {
  type        = string
  default     = "10.0.0.0/16"
  description = "CIDR block for the VPC."
}

variable "public_subnet_cidrs" {
  type        = list(string)
  default     = ["10.0.1.0/24", "10.0.2.0/24"]
  description = "CIDR blocks for the public subnets."
}

variable "private_subnet_cidrs" {
  type        = list(string)
  default     = ["10.0.3.0/24"]
  description = "CIDR blocks for the private subnets."
}

variable "availability_zone_1" {
  type        = string
  default     = "us-east-1a"
  description = "First availability zone."
}

variable "availability_zone_2" {
  type        = string
  default     = "us-east-1b"
  description = "Second availability zone."
}

variable "env" {
  type = string
  validation {
    condition     = can(regex("^[a-z0-9]{2,10}$", var.env))
    error_message = "env must be 2-10 lowercase alphanumeric characters"
  }
}
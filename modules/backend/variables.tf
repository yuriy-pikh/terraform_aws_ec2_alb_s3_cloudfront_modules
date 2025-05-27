variable "domain_name_api" {
  type        = string
  description = "The domain name for the API (e.g., api.example.com)."
}

variable "instance_type" {
  type        = string
  default     = "t2.micro"
  description = "EC2 instance type for the backend."
}

variable "ami_id" {
  type        = string
  default     = "ami-0f88e80871fd81e91" # Amazon Linux 2 AMI (HVM), SSD Volume Type in us-east-1
  description = "AMI ID for the EC2 instances. Ensure this AMI is available in the selected region."
}

variable "desired_capacity" {
  type        = number
  default     = 1
  description = "Desired number of instances in the ASG."
}

variable "min_size" {
  type        = number
  default     = 1
  description = "Minimum number of instances in the ASG."
}

variable "max_size" {
  type        = number
  default     = 3
  description = "Maximum number of instances in the ASG."
}

variable "env" {
  type = string
  validation {
    condition     = can(regex("^[a-z0-9]{2,15}$", var.env))
    error_message = "env must be 2-15 lowercase alphanumeric characters"
  }
}

# --- Змінні, що передаються з remote state ---
variable "vpc_id" {
  description = "The ID of the VPC where resources will be deployed."
  type        = string
}

variable "public_subnet_ids" {
  description = "A list of public subnet IDs for the ALB."
  type        = list(string)
}

variable "private_subnet_ids" {
  description = "A list of private subnet IDs for EC2 instances."
  type        = list(string)
}

variable "certificate_arn" {
  description = "The ARN of the ACM certificate for the ALB HTTPS listener."
  type        = string
}

variable "route53_zone_id" {
  description = "The Route 53 Hosted Zone ID where the ALB alias record will be created."
  type        = string
}
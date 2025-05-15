variable "domain_name_api" {
  type        = string
  description = "The domain name for the API (e.g., api.example.com)."
}

variable "env_name" {
  description = "The name of the environment (e.g., dev, staging, prod)."
  type        = string
}

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
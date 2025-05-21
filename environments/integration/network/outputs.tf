output "vpc_id" {
  description = "The ID of the main VPC created by this module."
  value       = module.network.vpc_id
}

output "vpc_cidr_block" {
  description = "The CIDR block of the main VPC."
  value       = module.network.vpc_cidr_block
}

output "public_subnet_ids" {
  description = "A list of IDs of the public subnets."
  value       = module.network.public_subnet_ids
}

output "private_subnet_ids" {
  description = "A list of IDs of the private subnets."
  value       = module.network.private_subnet_ids
}

output "internet_gateway_id" {
  description = "The ID of the Internet Gateway."
  value       = module.network.internet_gateway_id
}

output "public_route_table_id" {
  description = "The ID of the public route table."
  value       = module.network.public_route_table_id
}

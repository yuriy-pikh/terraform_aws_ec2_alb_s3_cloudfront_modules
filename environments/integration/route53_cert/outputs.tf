output "certificate_arn" {
  description = "The ARN of the ACM certificate for the API domain."
  value       = module.route53_cert_api.certificate_arn
}

output "zone_id" {
  description = "The ID of the Route 53 Hosted Zone for the API domain."
  value       = module.route53_cert_api.zone_id
}

output "zone_name_servers" {
  description = "The Name Servers for the Hosted Zone for the API domain."
  value       = module.route53_cert_api.zone_name_servers
}

output "certificate_arn_route53_cert_app" {
  description = "The ARN of the ACM certificate for the API domain."
  value       = module.route53_cert_app.certificate_arn
}

output "zone_id_route53_cert_app" {
  description = "The ID of the Route 53 Hosted Zone for the API domain."
  value       = module.route53_cert_app.zone_id
}

output "zone_name_servers_route53_cert_app" {
  description = "The Name Servers for the Hosted Zone for the API domain."
  value       = module.route53_cert_app.zone_name_servers
}
output "zone_id" {
  description = "The ID of the Route 53 Hosted Zone created by this module."
  value       = aws_route53_zone.main.zone_id
}

output "zone_name_servers" {
  description = "The Name Servers for the Hosted Zone created by this module. Use these for delegation."
  value       = aws_route53_zone.main.name_servers
}

output "certificate_arn" {
  description = "The ARN of the ACM certificate created by this module."
  value       = aws_acm_certificate.cert.arn
}
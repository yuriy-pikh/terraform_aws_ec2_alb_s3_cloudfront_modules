output "route53_name_servers_info" {
  value = <<EOT
Name servers:
${join("\n", aws_route53_zone.main.name_servers)}
EOT
}

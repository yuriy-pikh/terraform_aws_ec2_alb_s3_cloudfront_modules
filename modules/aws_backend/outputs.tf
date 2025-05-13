output "route53_name_servers_info" {
  value = <<EOT
Copy the following name servers to your domain registrar (e.g. Namecheap) to delegate DNS to AWS Route 53.
After this, ACM validation and routing through your ALB will work.

Name servers:
${join("\n", aws_route53_zone.main.name_servers)}
EOT
}

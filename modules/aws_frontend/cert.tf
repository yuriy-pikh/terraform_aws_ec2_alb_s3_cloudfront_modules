resource "aws_route53_zone" "main" {
  name = var.domain_name_app
}

resource "aws_acm_certificate" "cert" {
  domain_name       = var.domain_name_app
  validation_method = "DNS"

  lifecycle {
    create_before_destroy = true
  }

  tags = {
    Name = "TLS certificate for ${var.domain_name_app}"
  }
}

resource "aws_route53_record" "cert_validation" {
  for_each = {
    for dvo in aws_acm_certificate.cert.domain_validation_options : dvo.domain_name => {
      name  = dvo.resource_record_name
      type  = dvo.resource_record_type
      value = dvo.resource_record_value
    }
  }

  zone_id = aws_route53_zone.main.zone_id
  name    = each.value.name
  type    = each.value.type
  records = [each.value.value]
  ttl     = 60
}

resource "aws_acm_certificate_validation" "cert_validation" {
  certificate_arn         = aws_acm_certificate.cert.arn
  validation_record_fqdns = [for record in aws_route53_record.cert_validation : record.fqdn]
}


resource "aws_route53_record" "site" {
  zone_id = aws_route53_zone.main.zone_id
  name    = var.domain_name_app
  type    = "A"

  alias {
    name                   = aws_cloudfront_distribution.this.domain_name # Corrected: Use the CloudFront distribution's domain name
    zone_id                = aws_cloudfront_distribution.this.hosted_zone_id # Correct: This is the CloudFront specific zone ID for alias records
    evaluate_target_health = false
  }
}
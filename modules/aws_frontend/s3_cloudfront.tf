resource "aws_s3_bucket" "this" {
  bucket = var.s3_name
}

resource "aws_s3_bucket_website_configuration" "this" {
  bucket = aws_s3_bucket.this.id

  index_document {
    suffix = "index.html"
  }

  error_document {
    key = "index.html" # SPA-friendly: serves index.html for 404s too
  }
}

resource "aws_s3_bucket_policy" "allow_cf" {
  bucket = aws_s3_bucket.this.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "AllowCloudFrontAccess"
        Effect = "Allow"
        Principal = {
          Service = "cloudfront.amazonaws.com"
        }
        Action   = "s3:GetObject"
        Resource = "${aws_s3_bucket.this.arn}/*"
        Condition = {
          StringEquals = {
            # "AWS:SourceArn" must reference the specific CloudFront distribution ARN
            "AWS:SourceArn" = aws_cloudfront_distribution.this.arn
          }
        }
      }
    ]
  })
}

resource "aws_s3_object" "index" {
  bucket       = aws_s3_bucket.this.id
  key          = "index.html"
  source       = "${path.module}/index.html" # Assumes index.html is in the module directory
  content_type = "text/html"
  etag         = filemd5("${path.module}/index.html") # Ensures object updates if file content changes
}

resource "aws_cloudfront_origin_access_control" "default" {
  name                              = "oac-${var.s3_name}" # Ensure unique name
  description                       = "OAC for S3 bucket ${var.s3_name}"
  origin_access_control_origin_type = "s3"
  signing_behavior                  = "always"
  signing_protocol                  = "sigv4"
}

locals {
  s3_origin_id = "s3-${var.s3_name}" # Ensure unique origin ID
}

resource "aws_cloudfront_distribution" "this" {
  enabled             = true
  default_root_object = "index.html"

  origin {
    domain_name              = aws_s3_bucket.this.bucket_regional_domain_name
    origin_id                = local.s3_origin_id
    origin_access_control_id = aws_cloudfront_origin_access_control.default.id # Use OAC
  }

  default_cache_behavior {
    allowed_methods        = ["GET", "HEAD", "OPTIONS"] # OPTIONS might be needed for CORS
    cached_methods         = ["GET", "HEAD"]
    target_origin_id       = local.s3_origin_id
    viewer_protocol_policy = "redirect-to-https"

    # Default TTL settings, can be adjusted
    default_ttl = 3600
    min_ttl     = 0
    max_ttl     = 86400

    forwarded_values { # Modern way is to use Cache Policy and Origin Request Policy
      query_string = false
      cookies {
        forward = "none"
      }
      headers = ["Origin"] # Forward Origin header if CORS is a concern
    }
  }

  viewer_certificate {
    acm_certificate_arn      = aws_acm_certificate.cert.arn
    ssl_support_method       = "sni-only"
    minimum_protocol_version = "TLSv1.2_2021"
  }

  aliases = [var.domain_name_app]

  restrictions {
    geo_restriction {
      restriction_type = "none" # Can be "whitelist" or "blacklist"
      # locations        = [] # Add country codes if restriction_type is not "none"
    }
  }

  price_class = "PriceClass_All" # Or PriceClass_200, PriceClass_100

  # Ensure ACM cert validation is complete before associating with CloudFront
  depends_on = [aws_acm_certificate_validation.cert_validation]

  # Recommended: Enable logging
  # logging_config {
  #   include_cookies = false
  #   bucket          = "my-cloudfront-logs.s3.amazonaws.com" # Create this S3 bucket separately
  #   prefix          = "${var.domain_name_app}/"
  # }

  # It's good practice to define custom error responses
  # custom_error_response {
  #   error_caching_min_ttl = 300
  #   error_code            = 403
  #   response_code         = 200
  #   response_page_path    = "/index.html"
  # }
  # custom_error_response {
  #   error_caching_min_ttl = 300
  #   error_code            = 404
  #   response_code         = 200
  #   response_page_path    = "/index.html"
  # }
}
resource "aws_cloudfront_origin_access_control" "current" {
  name                              = "OAC ${aws_s3_bucket.website.bucket}"
  origin_access_control_origin_type = "s3"
  signing_behavior                  = "always"
  signing_protocol                  = "sigv4"
}

resource "aws_cloudfront_distribution" "s3_distribution" {
  depends_on = [aws_s3_bucket.website]
  origin {
    domain_name              = aws_s3_bucket.website.bucket_regional_domain_name
    origin_id                = "${aws_s3_bucket.website.bucket}-origin"
    origin_access_control_id = aws_cloudfront_origin_access_control.current.id
    connection_attempts = 3
    connection_timeout = 10
  }
  comment         = "${aws_s3_bucket.website.bucket} distribution"
  enabled         = true
  is_ipv6_enabled = true
  http_version    = "http2and3"
  price_class     = "PriceClass_100" // Use only North America and Europe
  // wait_for_deployment = true
  aliases = [
    var.domain,
    "www.${var.domain}"
  ]
  default_root_object = "index.html"


  default_cache_behavior {
    cache_policy_id        = "658327ea-f89d-4fab-a63d-7e88639e58f6"
    viewer_protocol_policy = "redirect-to-https"
    allowed_methods        = ["DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT"]
    cached_methods         = ["GET", "HEAD"]
    compress               = true
    target_origin_id       = "${aws_s3_bucket.website.bucket}-origin"

    function_association {
      event_type   = "viewer-request"
      function_arn = aws_cloudfront_function.www_redirect.arn
    }
  }

  custom_error_response {
    error_code = 403
    error_caching_min_ttl = 300
    response_code = 200
    response_page_path = "/index.html"
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }
  viewer_certificate {
#    If certificate already exists, use data reference
#    acm_certificate_arn      = data.aws_acm_certificate.cert_validation.arn
    acm_certificate_arn      = aws_acm_certificate_validation.cert_validation.certificate_arn
    ssl_support_method       = "sni-only"
    minimum_protocol_version = "TLSv1.2_2021"
  }
}

# If acm certificate already exists, uncomment this block and remove acm_certificate,tf
#data "aws_acm_certificate" "cert_validation" {
#  provider    = aws.acm_provider
#  domain      = var.domain
#  types       = ["AMAZON_ISSUED"]
#  most_recent = true
#}


resource "aws_cloudfront_function" "www_redirect" {
  #  name    = "${local.prefix}-www-redirect"
  name    = "${replace(var.domain, ".", "_")}-www-redirect"
  runtime = "cloudfront-js-1.0"
  code    = file("./cloudfront-function.js")
  publish = true
}

resource "aws_route53_record" "root_a" {
  zone_id = data.aws_route53_zone.main.zone_id
  name    = var.domain
  type    = "A"

  alias {
    name                   = aws_cloudfront_distribution.s3_distribution.domain_name
    zone_id                = aws_cloudfront_distribution.s3_distribution.hosted_zone_id
    evaluate_target_health = false
  }
}

resource "aws_route53_record" "www_a" {
  zone_id = data.aws_route53_zone.main.zone_id
  name    = "www.${var.domain}"
  type    = "A"

  alias {
    name                   = aws_cloudfront_distribution.s3_distribution.domain_name
    zone_id                = aws_cloudfront_distribution.s3_distribution.hosted_zone_id
    evaluate_target_health = false
  }
}

output "cloudfront_url" {
  description = "Cloudfront distribution URL (HTTPS)"
  value       = "https://${aws_cloudfront_distribution.s3_distribution.domain_name}"
}

output "domain_url" {
  description = "Cloudfront distribution URL (HTTPS)"
  value       = "https://${var.domain}"
}

output "www_domain_url" {
  description = "Cloudfront distribution URL (HTTPS)"
  value       = "https://www.${var.domain}"
}
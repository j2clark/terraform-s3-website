
We are adding a Cloudfront function to redirect https://www.example.com => https://example.com


We need to update Cloudfront aliases to include www

```terraform
resource "aws_cloudfront_distribution" "s3_distribution" {
  aliases = [
    var.domain,
    "www.${var.domain}"
  ]

  function_association {
    event_type   = "viewer-request"
    function_arn = aws_cloudfront_function.www_redirect.arn
  }
}

resource "aws_cloudfront_function" "www_redirect" {
  #  name    = "${local.prefix}-www-redirect"
  name    = "${replace(var.domain, ".", "_")}-www-redirect"
  runtime = "cloudfront-js-1.0"
  code    = file("./cloudfront-function.js")
  publish = true
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
```
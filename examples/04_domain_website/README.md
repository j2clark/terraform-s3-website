We are expanding on [02_cloudfront_website](../02_cloudfront_website/README.md)

We added and validated an acm certificate in [03_domain_website_acm_certificate](../03_acm_certificate/README.md), which we will now use in our Cloudfront distribution 


## ACM Certificates
I like my examples to fully functional, so I am assuming an acm certificate will need to be created as part of deployment.

But I have added some commented out code which references an existing certificate.  


## Cloudfront Modifications

* Add domain alias
* Replace default certificate with acm certificate

```terraform
resource "aws_cloudfront_distribution" "s3_distribution" {
  aliases = [var.domain]

  viewer_certificate {
    #    cloudfront_default_certificate = true
    acm_certificate_arn      = aws_acm_certificate_validation.cert_validation.certificate_arn
  }
}
```

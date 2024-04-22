# Terraform Examples

Below is a list of examples I use to remind myself the important aspects of various parts of development.

Return to code after a couple of months hiatus, I will most likely forgotten very important details like 
```terraform
resource "aws_cloudfront_distribution" "s3_distribution" {
  origin {
    origin_access_control_id = aws_cloudfront_origin_access_control.current.id
  }
}
```
or
```terraform
resource "aws_cloudfront_distribution" "s3_distribution" {
  custom_error_response {
    error_code            = 403
    error_caching_min_ttl = 300
    response_code         = 200
    response_page_path    = "/index.html"
  }
}
```
Both of which represent themselves as **_AccessDenied_** errors, but for very different reasons.

## The How and Why's

I prefer to understand the _why_ of something as well as the how

Each example in a group is a stand-alone example on how to do something, but in combination they are meant to show the progression from very basic to relatively complete, with a README that describes the differences at a high level

I don't always want to deploy a full-fledged application backed by cloudfront, or behind a domain, so I can select my playground accordingly. 

### Each example is where necessary and will require parameter(s) to run.

The simple format is
```shell
terraform plan -var "param_name=param_value"
```

## The Examples

1. [S3 Website](./01_s3_website): Public S3 Website
2. [CloudFront Website](./02_cloudfront_website): CloudFront distribution fronting private S3 Bucket
3. [ACM Certificate (HTTPS)](./03_acm_certificate): Create an ACM Certificate (HTTPS); a preamble to Domain Backed Website 
4. [Domain Backed Website](./04_domain_website): `https://example.com` Website
5. [WWW (redirecting) Website](./05_www_domain_website): Redirects `https://www.example.com` -> `https://example.com` using CloudFront Function   
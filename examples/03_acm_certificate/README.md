An ACM Certificate is a prerequisite to hosting a Cloudfront website using a custom domain.

This certificate is what enables HTTPS requests

This section deals only with the steps required to create a certificate and validate it using Route53

A couple of things of note:

* Certificate validation is done by adding a DNS Record (or records) to your domain's hosted zone

* ACM Certificates are only valid when created in Zone **_us-east-1_**

    I work predominantly in us-west-1, so an additional configuration is required to enable this:
    ```terraform
    # this is the primary aws provider
    provider "aws" {
      region = "us-west-1"
    }
    
    # this is the us-east-1 aws provider
    # usage => provider = aws.acm_provider
    provider "aws" {
      region = "us-east-1"
      alias  = "acm_provider"
    }
    ```
  
* DNS Validation Method

  There are two validation methods: DNS, Email
    
  I prefer DNS since 
  * it is automatic (although you have to wait a few minutes)
  * You don't have to configure the domain to receive email 
  
  
* I have configured the certificate for both example.com and *.example.com
    
  We will have a single DNS record which supports all sub-domain requests  

  ```terraform
  resource "aws_acm_certificate" "ssl_certificate" {
    provider                  = aws.acm_provider
    domain_name               = var.domain
    subject_alternative_names = ["*.${var.domain}"]
    validation_method = "DNS"  
  }
  ```

  We will end up with one CNAME record in Hosted zone, which will look something like

| Record name                                   | Type  | Routing policy  |  Differentiator  | Alias  | Value/Route traffic to                                            |  TTL (seconds)  |  Health check ID  |  Evaluate target health  |  Record ID  |
|-----------------------------------------------|-------|:---------------:|:----------------:|:------:|-------------------------------------------------------------------|:---------------:|:-----------------:|:------------------------:|:-----------:|
| _7fda87757ede030ac41bd252f2642b33.example.com | CNAME |     Simple      |        -         |   No   | _4444fc03a5715cf678c0b5c0530fda27.hkvuiqjoua.acm-validations.aws. |       60        |         -         |            -             |      -      |
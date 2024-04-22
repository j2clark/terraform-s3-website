We are expanding on [01_static_website](../01_s3_website/README.md)

We are making the bucket private and hosting the website using cloudfront

Significant differences in policies are:

* Public Access Block Changes
    ```
    resource "aws_s3_bucket_public_access_block" "public_access_block" {
      bucket = aws_s3_bucket.website.id
    #  block_public_acls       = false
    #  block_public_policy     = false
    #  ignore_public_acls      = false
    #  restrict_public_buckets = false
      
      block_public_acls       = true
      block_public_policy     = true
      ignore_public_acls      = true
      restrict_public_buckets = true
    }
    ```

* The bucket policy changes, to restrict access only to a _specific_ cloudfront distribution using a Condition
    ```terraform
    statement {
    #  principals {
    #    type        = "AWS"
    #    identifiers = ["*"]
    #  }
      principals {
        type        = "Service"
        identifiers = ["cloudfront.amazonaws.com"]
      }
      condition {
        test     = "StringEquals"
        variable = "AWS:SourceArn"
        values = [
          aws_cloudfront_distribution.s3_distribution.arn
        ]
      }
    }
    ```
* We add a **_private_** ACL 
    ```terraform
    resource "aws_s3_bucket_ownership_controls" "website" {
      bucket = aws_s3_bucket.website.id
      rule {
        object_ownership = "BucketOwnerPreferred"
      }
    }
    
    resource "aws_s3_bucket_acl" "website_bucket" {
      bucket = aws_s3_bucket.website.id
      acl    = "private"
    }
    ```
  
* We add a Cloudfront Distribution

  The distribution itself is a tricky thing to get right, but with respect to security the `origin_access_control_id` is a make-or-break setting.

  ```terraform
  resource "aws_cloudfront_origin_access_control" "current" {
    name                              = "OAC ${aws_s3_bucket.website.bucket}"
    origin_access_control_origin_type = "s3"
    signing_behavior                  = "always"
    signing_protocol                  = "sigv4"
  }
  
  resource "aws_cloudfront_distribution" "s3_distribution" {
    origin {
      origin_id   = "${aws_s3_bucket.website.bucket}-origin"
    }
  }
  ```

  If you don't set this, you will see something like the following:
  ```text
  This XML file does not appear to have any style information associated with it. The document tree is shown below.
  <hr/>
  <Error>
      <Code>AccessDenied</Code>
      <Message>Access Denied</Message>
      <RequestId>VB9D3CS81T0C4JBG</RequestId>
      <HostId>vMARy/QCxwdem+jH0FrX57r5CB4HSGfdGvbf/u8JVf1UueKhkHj5fnroGeT6YmISqVxOkAlU02hsLzjVXut4RQ==</HostId>
  </Error>
  ```

* Not exactly security related, but if you have deploy a single page application with a index.html serving both normal and error conditions, you will want to configure a custom error response
  ```terraform
  resource "aws_cloudfront_distribution" "s3_distribution" {
    custom_error_response {
      error_code = 403
      error_caching_min_ttl = 300
      response_code = 200
      response_page_path = "/index.html"
    }
  }
  ```
  
  Without this configuration errors appear as AccessDenied errors, since the resource doesn't exists


* Finally, we change the output url from the S3 bucket url to the cloudfront url

  The s3 url should no longer work, since the bucket is now private 
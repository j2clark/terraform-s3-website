The very basics, setting up a static website hosted by S3

Note: Don't do this. This is just the first step in establishing differences in security settingts (IAM Policies)

[How to Create a simple static Amazon S3 website using Terraform](https://dev.to/aws-builders/how-to-create-a-simple-static-amazon-s3-website-using-terraform-43hc)

NOtes: He sets the bucket policy manually, which is not required nor recommended 

[Setting permissions for website access](https://docs.aws.amazon.com/AmazonS3/latest/userguide/WebsiteAccessPermissionsReqd.html)

In Terraform:
```terraform
data "aws_iam_policy_document" "website_access_policy" {
  statement {
    effect = "Allow"
    principals {
      identifiers = ["*"]
      type        = "AWS"
    }
    actions = [
      "s3:GetObject"
    ]
    resources = [
      "${aws_s3_bucket.website.arn}/*"
    ]
  }
}
```

Also important (and something I seem to get wrong a lot) is the _**bucket policy**_ dictates access

```terraform
data "aws_iam_policy_document" "website_access_policy" {
  statement {
    effect = "Allow"
    principals {
      identifiers = ["*"]
      type        = "AWS"
    }
    actions = [
      "s3:GetObject"
    ]
    resources = [
      "${aws_s3_bucket.website.arn}/*"
    ]
  }
}

resource "aws_s3_bucket_policy" "website_policy" {
  bucket  = aws_s3_bucket.website.bucket
  policy  = data.aws_iam_policy_document.website_access_policy.json
}
```
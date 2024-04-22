resource "aws_s3_bucket" "website" {
  bucket = var.domain
  force_destroy = true
}

resource "aws_s3_object" "upload_object" {
  for_each      = fileset("website/", "*")
  bucket        = aws_s3_bucket.website.id
  key           = each.value
  source        = "website/${each.value}"
  etag          = filemd5("website/${each.value}")
  content_type  = "text/html"
}


resource "aws_s3_bucket_public_access_block" "public_access_block" {
  bucket = aws_s3_bucket.website.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}


data "aws_iam_policy_document" "website_access_policy" {
  statement {
    effect = "Allow"
    principals {
      type        = "Service"
      identifiers = ["cloudfront.amazonaws.com"]
    }
    actions = [
      "s3:GetObject"
    ]
    resources = [
      "${aws_s3_bucket.website.arn}/*"
    ]
    condition {
      test     = "StringEquals"
      variable = "AWS:SourceArn"
      values = [
        aws_cloudfront_distribution.s3_distribution.arn
      ]
    }
  }
}

resource "aws_s3_bucket_policy" "website_policy" {
  bucket  = aws_s3_bucket.website.bucket
  policy  = data.aws_iam_policy_document.website_access_policy.json
}

resource "aws_s3_bucket_ownership_controls" "website" {
  bucket = aws_s3_bucket.website.id
  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

resource "aws_s3_bucket_acl" "website_bucket" {
  depends_on = [
    aws_s3_bucket_ownership_controls.website,
    aws_s3_bucket_public_access_block.public_access_block,
  ]

  bucket = aws_s3_bucket.website.id
  acl    = "private"
}

resource "aws_s3_bucket" "website" {
  bucket = "${var.bucket_name}"
  force_destroy = true
}

resource "aws_s3_bucket_website_configuration" "website_config" {
  bucket = aws_s3_bucket.website.id
  index_document {
    suffix = "index.html"
  }
  error_document {
    key = "index.html"
  }
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
  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}


data "aws_iam_policy_document" "website_access_policy" {
  statement {
    effect = "Allow"
    principals {
      type        = "AWS"
      identifiers = ["*"]
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

output "s3_url" {
  value = "http://${aws_s3_bucket.website.bucket_regional_domain_name}/index.html"
}
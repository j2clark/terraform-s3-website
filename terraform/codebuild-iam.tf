resource "aws_iam_role" "codebuild_role" {
  name = "codebuild-role-${var.prefix}"
  assume_role_policy = jsonencode(
    {
      "Version" : "2012-10-17",
      "Statement" : [
        {
          "Effect" : "Allow",
          "Principal" : {
            "Service" : "codebuild.amazonaws.com"
          },
          "Action" : "sts:AssumeRole"
        }
      ]
    }
  )
}

resource "aws_iam_policy" "codebuild_policy" {
  name = "codebuild-policy-${var.prefix}"
  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "logs:CreateLogGroup",
        "logs:CreateLogStream",
        "logs:PutLogEvents"
      ],
      "Resource": [
        "arn:aws:logs:${data.aws_region.current.id}:${data.aws_caller_identity.current.account_id}:log-group:/aws/codebuild/${var.prefix}-frontend*",
        "arn:aws:logs:${data.aws_region.current.id}:${data.aws_caller_identity.current.account_id}:log-group:/aws/codebuild/${var.prefix}-frontend*:*"
      ]
    },
    {
      "Effect": "Allow",
      "Action": [
        "s3:List*",
        "s3:PutObject*",
        "s3:GetObject*",
        "s3:DeleteObject*",
        "s3:GetBucket*"
      ],
      "Resource": [
        "${aws_s3_bucket.static_website.arn}",
        "${aws_s3_bucket.static_website.arn}/*"
      ]
    },
    {
      "Effect": "Allow",
      "Action": [
        "codebuild:CreateReportGroup",
        "codebuild:CreateReport",
        "codebuild:UpdateReport",
        "codebuild:BatchPutTestCases",
        "codebuild:BatchPutCodeCoverages"
      ],
      "Resource": [
        "arn:aws:codebuild:${data.aws_region.current.id}:${data.aws_caller_identity.current.account_id}:report-group/codebuild-policy-${var.prefix}-frontend*"
      ]
    },
    {
      "Effect": "Allow",
      "Action": [
        "cloudfront:CreateInvalidation"
      ],
      "Resource": [
        "${aws_cloudfront_distribution.s3_distribution.arn}"
      ]
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "codebuild-role-policy-attachment" {
  role       = aws_iam_role.codebuild_role.name
  policy_arn = aws_iam_policy.codebuild_policy.arn
}
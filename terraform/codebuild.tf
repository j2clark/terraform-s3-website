resource "aws_codebuild_project" "codebuild" {
  name         = "${var.prefix}-frontend-${var.branch}"
  service_role = aws_iam_role.codebuild_role.arn

  source {
    type            = "GITHUB"
    location        = "https://github.com/${var.github_repo}"
    git_clone_depth = 1
    ## use the buildspec provided by the repo
    buildspec       = "buildspec.yml"
  }

  environment {
    compute_type    = "BUILD_GENERAL1_SMALL"
    image           = "aws/codebuild/standard:5.0"
    type            = "LINUX_CONTAINER"

    environment_variable {
      ## used by buildspec when copying files
      name  = "website_bucket"
      value = aws_s3_bucket.static_website.bucket
    }

    environment_variable {
      ## used by buildspec to invalidate cloudfront distribution
      name  = "cloudfront_id"
      value = aws_cloudfront_distribution.s3_distribution.id
    }
  }

  artifacts {
    ## buildspec copies files to S3 - no artifacts required
    type = "NO_ARTIFACTS"
  }

  tags = var.common_tags
}
terraform {
  required_providers {
    heroku = {
      source = "heroku/heroku"
      version = "~> 4.6"
    }
    github = {
      source = "integrations/github"
      version = "~> 6.0"
    }
    aws = {
      source = "hashicorp/aws"
      version = "5.37.0"
    }
  }
#  backend "s3" {
#    bucket = "terraform state bucket"
#    key = "tfstate file"
#    region = "us-west-1"
#  }
}

provider "heroku" {}

provider "github" {}

## this is used to ensure we are using us-east-1 for certificates
## usage is provider = aws.<alias>
## provider = aws.us-east-1
provider "aws" {
  region = "us-east-1"
  alias  = "acm_provider"
}
provider "aws" {
  region = "us-west-1"
}

data "aws_caller_identity" "current" {}

data "aws_region" "current" {}

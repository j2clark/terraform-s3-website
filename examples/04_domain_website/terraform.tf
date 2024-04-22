terraform {
  required_providers {
    heroku = {
      source = "heroku/heroku"
      version = "~> 4.6"
    }
    aws = {
      source = "hashicorp/aws"
      version = "5.37.0"
    }
  }
}

provider "heroku" {}

provider "aws" {
  region = "us-west-1"
}

provider "aws" {
  region = "us-east-1"
  alias  = "acm_provider"
}

variable "domain" {
  description = "The domain you are deploying, e.g. example.com"
}
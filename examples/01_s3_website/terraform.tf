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

variable "bucket_name" {
  description = "The name of the bucket to host website, e.g. example.com"
}
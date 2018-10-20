provider "aws" {
  region = "eu-west-1"
}

data "aws_caller_identity" "account" {}

data "aws_region" "region" {}

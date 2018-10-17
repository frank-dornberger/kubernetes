terraform {
  backend "s3" {
    bucket = "frank-terraform-state-bucket"
    key    = "kubernetes/dev.tfstate"
    region = "eu-west-1"
  }
}

provider "aws" {
  region = "${var.region}"
}

locals {
  common_tags = {
    Terraform   = "true"
    Environment = "dev"
  }
}

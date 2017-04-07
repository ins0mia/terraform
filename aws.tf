terraform {
    required_version = "> 0.8.0"
    backend "s3" {
      bucket = "insomia-test-terraform-state"
      key = "/terraform.tfstate"
      region = "us-west-2"
    }
}

provider "aws" {
  region = "${var.aws_region}"
}

resource "aws_s3_bucket" "state" {
  bucket = "${var.project_name}-terraform-state"
  acl    = "private"

  versioning {
    enabled = true
  }

  lifecycle_rule {
    enabled = true
    prefix = "/"
    noncurrent_version_expiration {
      days = 30
    }
  }

  tags {
    Name = "${var.project_name} terraform bucket"
  }
}

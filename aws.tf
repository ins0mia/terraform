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

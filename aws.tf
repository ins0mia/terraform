terraform {
    required_version = "> 0.8.0"
}

provider "aws" {
  region = "${var.aws_region}"
}

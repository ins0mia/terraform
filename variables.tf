variable "aws_key_name" {
  default = "aws"
}

variable "aws_region" {
    description = "EC2 Region for the VPC"
    default = "us-west-2"
}

variable "ec2_az" {
  description = "Zones for ec2 instances"
  type = "list"
  default = ["us-west-2a", "us-west-2b", "us-west-2c"]
}

variable "ec2_subnet_cidr" {
  description = "CIDR for ec2 instances"
  type = "list"
  default = ["10.0.10.0/24", "10.0.20.0/24", "10.0.30.0/24"]
}

variable "project_name" {
  default = "insomia-test"
}

variable "ami" {
    description = "custom ami: ubuntu 16.04, php5.6, nginx, codedeploy-agent"
    default = "ami-50a13130"
}

variable "vpc_cidr" {
    description = "CIDR for the whole VPC"
    default = "10.0.0.0/16"
}

variable "allowed_ip_to_access_rds" {
  type = "list"
  description = "list of allowed ips to access to rds instance for backups, maintance, etc."
  default = ["1.2.3.4/32", "5.5.6.7/32"]
}

variable "instance_type" {
  description = "type of instances for launch configuration"
  default = "t2.micro"
}

variable "instance_class" {
  description = "type of instances for rds"
  default = "t2.micro"
}

variable "db_name" {
  default = "test"
}

variable "db_username" {
  default = "test"
}

variable "db_password" {
  default = "XXXXXXX"
}

variable "domain_name" {
  description = "domain names"
  default = "example.com"
}

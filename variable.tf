# --- root/variables.tf ---

variable "aws_region" {
  default = "us-east-1"
}
variable "region" {}
variable "vpc_cidr" {}
variable "environment" {}
variable "public_subnets_cidr" {}
variable "private_subnets_cidr" {}
variable "availability_zones" {}

# ------ ./modules/networking/variables.tf ------

variable "aws_region" {
  default = "us-west-2"
}
variable "vpc_cidr" {}
variable "environment" {}
variable "public_subnets_cidr" {}
variable "private_subnets_cidr" {}
variable "availability_zones" {}
variable "private_db_subnets_cidr" {}
variable "subnate_group_name" {}

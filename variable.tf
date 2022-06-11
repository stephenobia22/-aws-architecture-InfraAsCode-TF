# ------ ./modules/networking/variables.tf ------

# variable "public_subnet_numbers" {
#     type = map(number)

#     description = "Map of AZ to a number that should be used for public subnet"

#     default = {
#         "us-west-1a" = 1
#         "us-west-1b" = 2
#         # "us-west-1c" = 3
#         # "us-west-1d" = 4
#     }
# }

# variable "private_subnet_numbers" {
#     type = map(number)

#     description = "Map of AZ to a number that should be used for private subnet"

#     default = {
#         "us-west-1a" = 3
#         "us-west-1b" = 4
#         # "us-west-1c" = 3
#         # "us-west-1d" = 4
#     }
# }

# variable "vpc_cidr" {
#     type = string
#     description = "The IP range to use for the VPC"
#     default  = "10.0.0.0/16"
# }


# variable "infra_env" {
#     type = string
#     description = "infrastructure environment"
# }

variable "aws_region" {
  default = "us-west-1"
}
variable "vpc_cidr" {}
variable "environment" {}
variable "public_subnets_cidr" {}
variable "private_subnets_cidr" {}
variable "availability_zones" {}

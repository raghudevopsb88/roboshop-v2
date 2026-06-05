variable "env" {}
variable "vpc_cidr" {}
variable "secondary_vpc_cidr" {
  type    = string
  default = ""
}
variable "subnets" {}
variable "az" {}
variable "default_vpc_id" {}
variable "default_vpc_rt_id" {}
variable "default_vpc_cidr" {}

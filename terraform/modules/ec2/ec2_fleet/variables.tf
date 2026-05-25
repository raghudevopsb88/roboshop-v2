variable "env" {}
variable "tier" {}
variable "instances" {}
variable "ami_id" {}
variable "ec2_user" {}
variable "ec2_password" { sensitive = true }
variable "subnet_ids" {}
variable "security_group_ids" {}
variable "route53_zone_id" {}
variable "dns_zone" {}
variable "kms_key_id" { type = string }
variable "tags" { type = map(string) }
variable "user_data_vars" {}

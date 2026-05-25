variable "env" {}
variable "vpc_id" {}
variable "vpc_cidr" {}
variable "subnet_ids" {}
variable "db_instances" {}
variable "ami_id" {}
variable "ec2_user" {
  type    = string
  default = "ec2-user"
}
variable "ec2_password" {
  type      = string
  sensitive = true
}
variable "ansible_repo_url" {}
variable "artifact_base_url" {}
variable "ssh_cidr_blocks" { type = list(string) }
variable "tags" {
  type    = map(string)
  default = {}
}

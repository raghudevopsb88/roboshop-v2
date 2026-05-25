variable "aws_region" {
  type    = string
  default = "us-east-1"
}

variable "env" {
  type = string
}

variable "tags" {
  type    = map(string)
  default = {}
}

variable "network" {
  type = map(object({
    vpc_cidr = string
    subnets = object({
      public_subnets = list(string)
      app_subnets    = list(string)
      db_subnets     = list(string)
    })
    az = list(string)
  }))
}

variable "kms_key_id" {
  type        = string
  description = "KMS key ARN for EKS secrets encryption and encrypted node volumes"
}

variable "cluster_version" {
  type    = string
  default = "1.31"
}

variable "dns_domain" {
  type        = string
  description = "Public DNS domain for ingress (e.g. example.com.)"
  default     = ""
}

variable "acm_certificate_arn" {
  type        = string
  description = "ACM certificate ARN for Traefik NLB TLS termination"
  default     = ""
}

variable "db_instances" {
  type = map(object({
    component           = string
    subnet_type         = string
    instance_type       = string
    subnet_index        = optional(number, 0)
    associate_public_ip = optional(bool, false)
    security_group      = string
  }))
}

variable "ami_id" {
  type = string
}

variable "ec2_user" {
  type    = string
  default = "ec2-user"
}

variable "ec2_password" {
  type      = string
  sensitive = true
}

variable "ansible_repo_url" {
  type    = string
  default = "https://github.com/raghudevopsb88/roboshop-v1.git"
}

variable "artifact_base_url" {
  type    = string
  default = "https://raw.githubusercontent.com/raghudevopsb88/roboshop-microservices-documentation/main/artifacts"
}

variable "ssh_cidr_blocks" {
  type        = list(string)
  description = "CIDR blocks allowed to SSH into DB instances (use default VPC / bastion CIDR)"
  default     = ["172.31.0.0/16"]
}

variable "node_instance_types" {
  type    = list(string)
  default = ["t3.xlarge"]
}

variable "node_desired_size" {
  type    = number
  default = 2
}

variable "node_min_size" {
  type    = number
  default = 2
}

variable "node_max_size" {
  type    = number
  default = 5
}

variable "node_capacity_type" {
  type    = string
  default = "SPOT"
}

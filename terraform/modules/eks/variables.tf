variable "env" {}
variable "kms_key_id" {}
variable "cluster_version" { default = "1.31" }
variable "vpc_id" {}
variable "subnets" { type = list(string) }
variable "cluster_subnets" {
  type        = list(string)
  default     = null
  description = "All subnets for the EKS control plane. Defaults to node subnets."
}
variable "default_vpc_cidr" {}
variable "dns_domain" { default = "" }
variable "acm_certificate_arn" { default = "" }
variable "node_instance_types" { type = list(string) }
variable "node_desired_size" { type = number }
variable "node_min_size" { type = number }
variable "node_max_size" { type = number }
variable "node_capacity_type" { type = string }
variable "db_service_hosts" { type = map(string) }

variable "app_namespace" {
  type        = string
  default     = "roboshop"
  description = "Kubernetes namespace where RoboShop app service accounts run"
}

variable "istio_version" {
  type        = string
  default     = "1.30.0"
  description = "Istio Helm chart version for istio-base and istiod"
}

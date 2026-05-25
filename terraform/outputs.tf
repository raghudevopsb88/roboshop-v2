output "vpc_id" {
  value = module.vpc[var.env].vpc_id
}

output "default_vpc_id" {
  value = data.aws_vpc.default.id
}

output "default_vpc_cidr" {
  value = data.aws_vpc.default.cidr_block
}

output "db_private_ips" {
  value = module.ec2.private_ips
}

output "db_service_hosts" {
  value = module.ec2.service_hosts
}

output "private_dns_zone" {
  value = module.ec2.dns_zone
}

output "eks_cluster_name" {
  value = module.eks.cluster_name
}

output "eks_cluster_endpoint" {
  value     = module.eks.cluster_endpoint
  sensitive = true
}

output "eks_cluster_certificate_authority" {
  value     = module.eks.cluster_certificate_authority
  sensitive = true
}

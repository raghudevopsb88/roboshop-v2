output "cluster_name" {
  value = aws_eks_cluster.main.name
}

output "cluster_endpoint" {
  value = aws_eks_cluster.main.endpoint
}

output "cluster_certificate_authority" {
  value = aws_eks_cluster.main.certificate_authority[0].data
}

output "cluster_security_group_id" {
  value = aws_eks_cluster.main.vpc_config[0].cluster_security_group_id
}

output "kms_key_arn" {
  value = var.kms_key_id
}

output "roboshop_ssm_role_arn" {
  value = aws_iam_role.roboshop_ssm.arn
}

output "roboshop_service_accounts" {
  value = [for app in local.roboshop_apps : "roboshop-${app}"]
}

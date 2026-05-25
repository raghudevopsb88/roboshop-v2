output "dns_zone" {
  value = local.dns_zone
}

output "service_hosts" {
  value = local.service_hosts
}

output "private_ips" {
  value = module.ec2_db.private_ips
}

output "route53_zone_id" {
  value = aws_route53_zone.private.zone_id
}

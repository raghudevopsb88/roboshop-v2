module "ec2" {
  for_each = var.instances
  source   = "../instance"

  name                = "${var.env}-${each.key}"
  component           = each.value.component
  ami_id              = var.ami_id
  instance_type       = each.value.instance_type
  subnet_id           = var.subnet_ids[each.value.subnet_type][each.value.subnet_index]
  security_group_ids  = var.security_group_ids[each.value.security_group]
  associate_public_ip = lookup(each.value, "associate_public_ip", false)
  ec2_user            = var.ec2_user
  ec2_password        = var.ec2_password
  kms_key_id          = var.kms_key_id

  tags = merge(var.tags, {
    Environment = var.env
    Tier        = var.tier
  })

  user_data = templatefile("${path.module}/../instance/user-data.sh.tpl", merge(var.user_data_vars, {
    component      = each.value.component
    bootstrap_tier = var.tier
  }))
}

resource "aws_route53_record" "instance" {
  for_each = var.instances

  zone_id = var.route53_zone_id
  name    = "${each.key}.${var.dns_zone}"
  type    = "A"
  ttl     = 60
  records = [module.ec2[each.key].private_ip]
}

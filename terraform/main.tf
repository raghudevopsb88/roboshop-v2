data "aws_vpc" "default" {
  default = true
}

data "aws_route_table" "default" {
  vpc_id = data.aws_vpc.default.id

  filter {
    name   = "association.main"
    values = ["true"]
  }
}

data "aws_kms_alias" "ebs" {
  name = "alias/aws/ebs"
}

locals {
  network_key = var.env

  # Use account default EBS key when unset or still a template placeholder
  kms_key_arn = (
    var.kms_key_id == "" ||
    strcontains(var.kms_key_id, "ACCOUNT_ID") ||
    strcontains(var.kms_key_id, "KEY_ID")
  ) ? data.aws_kms_alias.ebs.target_key_arn : var.kms_key_id
}

module "vpc" {
  for_each = var.network
  source   = "./modules/vpc"

  env               = var.env
  vpc_cidr          = each.value.vpc_cidr
  subnets           = each.value.subnets
  az                = each.value.az
  default_vpc_id    = data.aws_vpc.default.id
  default_vpc_rt_id = data.aws_route_table.default.id
  default_vpc_cidr  = data.aws_vpc.default.cidr_block
}

module "ec2" {
  source = "./modules/ec2"

  env               = var.env
  vpc_id            = module.vpc[local.network_key].vpc_id
  vpc_cidr          = module.vpc[local.network_key].vpc_cidr
  subnet_ids        = module.vpc[local.network_key].subnet_ids
  db_instances      = var.db_instances
  ami_id            = var.ami_id
  ec2_user          = var.ec2_user
  ec2_password      = var.ec2_password
  ansible_repo_url  = var.ansible_repo_url
  artifact_base_url = var.artifact_base_url
  ssh_cidr_blocks   = concat(var.ssh_cidr_blocks, [module.vpc[local.network_key].vpc_cidr])
  tags              = var.tags
}

module "eks" {
  source = "./modules/eks"

  env                 = var.env
  kms_key_id          = local.kms_key_arn
  cluster_version     = var.cluster_version
  vpc_id              = module.vpc[local.network_key].vpc_id
  subnets             = module.vpc[local.network_key].app_subnet_ids
  default_vpc_cidr    = data.aws_vpc.default.cidr_block
  dns_domain          = var.dns_domain
  acm_certificate_arn = var.acm_certificate_arn
  node_instance_types = var.node_instance_types
  node_desired_size   = var.node_desired_size
  node_min_size       = var.node_min_size
  node_max_size       = var.node_max_size
  node_capacity_type  = var.node_capacity_type
  db_service_hosts    = module.ec2.service_hosts
}

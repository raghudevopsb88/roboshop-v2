locals {
  dns_zone = "${var.env}.roboshop.internal"

  service_hosts = {
    mysql    = "mysql.${local.dns_zone}"
    mongodb  = "mongodb.${local.dns_zone}"
    valkey   = "valkey.${local.dns_zone}"
    rabbitmq = "rabbitmq.${local.dns_zone}"
  }

  user_data_common = {
    ansible_repo_url  = var.ansible_repo_url
    artifact_base_url = var.artifact_base_url
    env               = var.env
    ec2_user          = var.ec2_user
    ec2_password      = var.ec2_password
    mysql_host        = local.service_hosts.mysql
    mongodb_host      = local.service_hosts.mongodb
    valkey_host       = local.service_hosts.valkey
    rabbitmq_host     = local.service_hosts.rabbitmq
    catalogue_host    = "catalogue.${local.dns_zone}"
    user_host         = "user.${local.dns_zone}"
    cart_host         = "cart.${local.dns_zone}"
    shipping_host     = "shipping.${local.dns_zone}"
    payment_host      = "payment.${local.dns_zone}"
    notification_host = "notification.${local.dns_zone}"
    orders_host       = "orders.${local.dns_zone}"
    ratings_host      = "ratings.${local.dns_zone}"
    frontend_host     = "frontend.${local.dns_zone}"
    wait_hosts        = ""
  }
}

resource "aws_route53_zone" "private" {
  name = local.dns_zone

  vpc {
    vpc_id = var.vpc_id
  }

  tags = {
    Name = "${var.env}-roboshop-private-zone"
  }
}

resource "aws_security_group" "db" {
  name        = "${var.env}-roboshop-db-sg"
  description = "RoboShop databases and message broker"
  vpc_id      = var.vpc_id

  ingress {
    description = "SSH from bastion / default VPC"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = var.ssh_cidr_blocks
  }

  ingress {
    description = "MySQL from VPC and EKS"
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    cidr_blocks = [var.vpc_cidr]
  }

  ingress {
    description = "MongoDB"
    from_port   = 27017
    to_port     = 27017
    protocol    = "tcp"
    cidr_blocks = [var.vpc_cidr]
  }

  ingress {
    description = "Valkey"
    from_port   = 6379
    to_port     = 6379
    protocol    = "tcp"
    cidr_blocks = [var.vpc_cidr]
  }

  ingress {
    description = "RabbitMQ AMQP"
    from_port   = 5672
    to_port     = 5672
    protocol    = "tcp"
    cidr_blocks = [var.vpc_cidr]
  }

  ingress {
    description = "RabbitMQ management"
    from_port   = 15672
    to_port     = 15672
    protocol    = "tcp"
    cidr_blocks = [var.vpc_cidr]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.env}-db-sg"
  }
}

locals {
  security_group_ids = {
    db = [aws_security_group.db.id]
  }
}

module "ec2_db" {
  source = "./ec2_fleet"

  env                = var.env
  tier               = "db"
  instances          = var.db_instances
  ami_id             = var.ami_id
  ec2_user           = var.ec2_user
  ec2_password       = var.ec2_password
  subnet_ids         = var.subnet_ids
  security_group_ids = local.security_group_ids
  route53_zone_id    = aws_route53_zone.private.zone_id
  dns_zone           = local.dns_zone
  tags               = var.tags
  user_data_vars     = local.user_data_common
}

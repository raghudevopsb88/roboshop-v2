env        = "dev"
aws_region = "us-east-1"

# RHEL 10 AMI (us-east-1) — update if your account uses a different AMI
ami_id       = "ami-0220d79f3f480ecf5"
ec2_user     = "ec2-user"
ec2_password = "DevOps321"

ansible_repo_url = "https://github.com/raghudevopsb88/roboshop-v1.git"

kms_key_id = "arn:aws:kms:us-east-1:739561048503:key/6a83bdae-47d1-4774-9fae-dafe28349ade"

# Public ingress (Traefik NLB) — optional until you have DNS/ACM
dns_domain          = "raghudevopsb88.online"
acm_certificate_arn = "arn:aws:acm:us-east-1:739561048503:certificate/357141e3-f378-4020-a8f5-b9d69a94316f"

cluster_version = "1.35"

network = {
  dev = {
    vpc_cidr = "10.30.0.0/24"
    subnets = {
      public_subnets = ["10.30.0.0/27", "10.30.0.32/27"]
      db_subnets     = ["10.30.0.64/27", "10.30.0.96/27"]
      app_subnets    = ["10.30.0.128/26", "10.30.0.192/26"]
    }
    az = ["us-east-1a", "us-east-1b"]
  }
}

# DB tier only — apps run on EKS (see helm/charts)
db_instances = {
  mysql = {
    component      = "mysql"
    subnet_type    = "db"
    subnet_index   = 0
    instance_type  = "t3.small"
    security_group = "db"
  }
  mongodb = {
    component      = "mongodb"
    subnet_type    = "db"
    subnet_index   = 1
    instance_type  = "t3.small"
    security_group = "db"
  }
  valkey = {
    component      = "valkey"
    subnet_type    = "db"
    subnet_index   = 0
    instance_type  = "t3.small"
    security_group = "db"
  }
  rabbitmq = {
    component      = "rabbitmq"
    subnet_type    = "db"
    subnet_index   = 1
    instance_type  = "t3.small"
    security_group = "db"
  }
}

node_instance_types = ["t3.xlarge"]
node_desired_size   = 2
node_min_size       = 2
node_max_size       = 5
node_capacity_type  = "SPOT"

# SSH from default VPC (bastion instance)
ssh_cidr_blocks = ["172.31.0.0/16"]

tags = {
  Project = "roboshop"
}

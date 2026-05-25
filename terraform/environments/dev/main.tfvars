env        = "dev"
aws_region = "us-east-1"

# RHEL 10 AMI (us-east-1) — update if your account uses a different AMI
ami_id       = "ami-0220d79f3f480ecf5"
ec2_user     = "ec2-user"
ec2_password = "DevOps321"

ansible_repo_url = "https://github.com/raghudevopsb88/roboshop-v1.git"

# Replace with your KMS key ARN
kms_key_id = "arn:aws:kms:us-east-1:ACCOUNT_ID:key/KEY_ID"

# Public ingress (Traefik NLB) — optional until you have DNS/ACM
dns_domain          = ""
acm_certificate_arn = ""

cluster_version = "1.31"

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

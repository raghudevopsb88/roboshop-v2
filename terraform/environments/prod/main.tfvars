env        = "prod"
aws_region = "us-east-1"

ami_id       = "ami-0220d79f3f480ecf5"
ec2_user     = "ec2-user"
ec2_password = "CHANGE_ME"

ansible_repo_url = "https://github.com/raghudevopsb88/roboshop-v1.git"

kms_key_id          = ""
dns_domain          = "example.com."
acm_certificate_arn = "arn:aws:acm:us-east-1:ACCOUNT_ID:certificate/CERT_ID"

cluster_version = "1.31"

network = {
  prod = {
    vpc_cidr = "10.40.0.0/24"
    subnets = {
      public_subnets = ["10.40.0.0/27", "10.40.0.32/27"]
      db_subnets     = ["10.40.0.64/27", "10.40.0.96/27"]
      app_subnets    = ["10.40.0.128/26", "10.40.0.192/26"]
    }
    az = ["us-east-1a", "us-east-1b"]
  }
}

db_instances = {
  mysql = {
    component      = "mysql"
    subnet_type    = "db"
    subnet_index   = 0
    instance_type  = "t3.medium"
    security_group = "db"
  }
  mongodb = {
    component      = "mongodb"
    subnet_type    = "db"
    subnet_index   = 1
    instance_type  = "t3.medium"
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
node_desired_size   = 3
node_min_size       = 2
node_max_size       = 10
node_capacity_type  = "ON_DEMAND"

ssh_cidr_blocks = ["172.31.0.0/16"]

tags = {
  Project = "roboshop"
}

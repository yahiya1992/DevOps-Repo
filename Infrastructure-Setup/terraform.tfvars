profile       = "service-account"
region        = "us-east-1"
environment   = "dev"
vpc_name      = "dev-vpc"
cluster_name  = "dev-eks-us-east-1"

azs = ["us-east-1a", "us-east-1b", "us-east-1c"]

cidr = "10.0.0.0/16"

public_subnets  = ["10.0.0.0/24", "10.0.1.0/24", "10.0.2.0/24"]
private_subnets = ["10.0.3.0/24", "10.0.4.0/24", "10.0.5.0/24"]
database_subnets = ["10.0.6.0/24", "10.0.7.0/24", "10.0.8.0/24"]

worker_groups_name = "worker-group"
key_name           = "dev-eks-key"

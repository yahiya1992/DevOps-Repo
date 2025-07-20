variable "profile" {}
variable "region" {}
variable "environment" {}
variable "vpc_name" {}
variable "cluster_name" {}
variable "azs" { type = list(string) }
variable "cidr" {}
variable "public_subnets" { type = list(string) }
variable "private_subnets" { type = list(string) }
variable "database_subnets" { type = list(string) }

variable "enable_nat_gateway" { default = true }
variable "single_nat_gateway" { default = true }
variable "one_nat_gateway_per_az" { default = false }
variable "enable_dns_hostnames" { default = true }

variable "cluster_version" { default = "1.22" }
variable "worker_groups_name" {}
variable "instance_type" { default = "t3a.large" }
variable "asg_min_size" { default = 2 }
variable "asg_max_size" { default = 5 }
variable "asg_desired_capacity" { default = 2 }
variable "key_name" {}

# RDS variables
variable "db_name" { default = "postgresdb" }
variable "db_username" { default = "admin" }
variable "db_instance_class" { default = "db.t3.medium" }
variable "db_engine_version" { default = "15.2" }
variable "db_allocated_storage" { default = 50 }
variable "db_multi_az" { default = false }
variable "db_backup_retention_period" { default = 7 }
variable "db_allowed_cidrs" { type = list(string), default = ["10.0.0.0/16"] }

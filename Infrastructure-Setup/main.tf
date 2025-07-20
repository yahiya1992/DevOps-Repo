provider "aws" {
  region  = var.region
  profile = var.profile

  default_tags {
    tags = {
      Environment = var.environment
      Product     = "Platform"
    }
  }
}

data "aws_secretsmanager_secret_version" "db_password" {
  secret_id = "dev/db-password"
}
# ------------------------------------------------------------------------------
# VPC Module
# ------------------------------------------------------------------------------
module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "3.14.2"

  name                                 = "${var.vpc_name}-${var.region}"
  cidr                                 = var.cidr
  azs                                  = var.azs
  public_subnets                       = var.public_subnets
  private_subnets                      = var.private_subnets
  database_subnets                     = var.database_subnets
  enable_nat_gateway                   = var.enable_nat_gateway
  single_nat_gateway                   = var.single_nat_gateway
  one_nat_gateway_per_az               = var.one_nat_gateway_per_az
  enable_dns_hostnames                 = var.enable_dns_hostnames
  enable_flow_log                      = true
  create_flow_log_cloudwatch_log_group = true
  create_flow_log_cloudwatch_iam_role  = true
  flow_log_max_aggregation_interval    = 60

  private_subnet_tags = {
    "kubernetes.io/cluster/${var.cluster_name}" = "owned"
    "karpenter.sh/discovery"                    = var.cluster_name
    "Name"                                      = "Private_Subnet_${var.cluster_name}"
  }

  database_subnet_tags = {
    "Name" = "Database_Subnet_${var.cluster_name}"
  }
}

# ------------------------------------------------------------------------------
# EKS Module
# ------------------------------------------------------------------------------
module "eks" {
  source                          = "terraform-aws-modules/eks/aws"
  version                         = "17.0.3"
  cluster_name                    = var.cluster_name
  cluster_version                 = var.cluster_version
  vpc_id                          = module.vpc.vpc_id
  subnets                         = module.vpc.private_subnets
  write_kubeconfig                = true
  kubeconfig_output_path          = "./config"
  manage_aws_auth                 = true
  cluster_endpoint_private_access = true
  cluster_endpoint_public_access  = true

  workers_group_defaults = {
    root_volume_type = "gp2"
    root_encrypted   = true
    root_volume_size = 100
  }

  worker_groups = [
    {
      name                          = "${var.worker_groups_name}-1"
      instance_type                 = var.instance_type
      asg_desired_capacity          = var.asg_desired_capacity
      asg_max_size                  = var.asg_max_size
      asg_min_size                  = var.asg_min_size
      key_name                      = var.key_name
      additional_security_group_ids = [aws_security_group.worker_group.id]
      public_ip                     = false
    },
    {
      name                          = "${var.worker_groups_name}-2"
      instance_type                 = var.instance_type
      asg_desired_capacity          = 1
      asg_max_size                  = 1
      asg_min_size                  = 1
      key_name                      = var.key_name
      additional_security_group_ids = [aws_security_group.worker_group.id]
      public_ip                     = false
    }
  ]
}

resource "aws_security_group" "worker_group" {
  name_prefix = "eks-worker-group"
  vpc_id      = module.vpc.vpc_id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [module.vpc.vpc_cidr_block]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# ------------------------------------------------------------------------------
# PostgreSQL RDS
# ------------------------------------------------------------------------------
resource "aws_db_subnet_group" "postgres" {
  name       = "${var.cluster_name}-postgres-subnet-group"
  subnet_ids = module.vpc.database_subnets

  tags = {
    Name = "${var.cluster_name}-postgres-subnet-group"
  }
}

resource "aws_security_group" "postgres_sg" {
  name        = "${var.cluster_name}-postgres-sg"
  description = "Allow PostgreSQL access"
  vpc_id      = module.vpc.vpc_id

  ingress {
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    cidr_blocks = var.db_allowed_cidrs
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.cluster_name}-postgres-sg"
  }
}

resource "aws_db_instance" "postgres" {
  identifier              = "${var.cluster_name}-postgres"
  allocated_storage       = var.db_allocated_storage
  engine                  = "postgres"
  engine_version          = var.db_engine_version
  instance_class          = var.db_instance_class
  name                    = var.db_name
  username                = var.db_username
  password                = data.aws_secretsmanager_secret_version.db_password.secret_string
  db_subnet_group_name    = aws_db_subnet_group.postgres.name
  vpc_security_group_ids  = [aws_security_group.postgres_sg.id]
  skip_final_snapshot     = true
  publicly_accessible     = false
  multi_az                = var.db_multi_az
  storage_encrypted       = true
  backup_retention_period = var.db_backup_retention_period
  apply_immediately       = true

  tags = {
    Name = "${var.cluster_name}-postgres"
  }
}

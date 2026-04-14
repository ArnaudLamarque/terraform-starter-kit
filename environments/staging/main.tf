terraform {
  required_version = ">= 1.6"
  required_providers {
    aws = { source = "hashicorp/aws", version = "~> 5.0" }
  }
  backend "s3" {
    bucket         = "YOUR_PROJECT-terraform-state"
    key            = "staging/terraform.tfstate"
    region         = "eu-west-1"
    dynamodb_table = "YOUR_PROJECT-terraform-locks"
    encrypt        = true
  }
}

provider "aws" {
  region = var.aws_region
  default_tags { tags = local.common_tags }
}

locals {
  env = "staging"
  common_tags = {
    Project     = var.project
    Environment = local.env
    ManagedBy   = "terraform"
  }
}

module "networking" {
  source             = "../../modules/networking"
  project            = var.project
  env                = local.env
  vpc_cidr           = "10.1.0.0/16"
  az_count           = 2
  single_nat_gateway = false # Multi-AZ NAT in staging
  tags               = local.common_tags
}

module "iam" {
  source         = "../../modules/iam"
  project        = var.project
  env            = local.env
  github_org     = var.github_org
  github_repo    = var.github_repo
  aws_region     = var.aws_region
  aws_account_id = var.aws_account_id
  tags           = local.common_tags
}

module "dns" {
  source       = "../../modules/dns"
  domain_name  = var.domain_name
  subdomain    = "staging"
  alb_dns_name = module.compute.alb_dns_name
  alb_zone_id  = module.compute.alb_zone_id
  tags         = local.common_tags
}

module "secrets" {
  source  = "../../modules/secrets"
  project = var.project
  env     = local.env
  secrets = var.app_secrets
  tags    = local.common_tags
}

module "compute" {
  source                      = "../../modules/compute"
  project                     = var.project
  env                         = local.env
  aws_region                  = var.aws_region
  vpc_id                      = module.networking.vpc_id
  public_subnet_ids           = module.networking.public_subnet_ids
  private_subnet_ids          = module.networking.private_subnet_ids
  ecs_task_execution_role_arn = module.iam.ecs_task_execution_role_arn
  ecs_task_role_arn           = module.iam.ecs_task_role_arn
  certificate_arn             = module.dns.certificate_arn
  container_port              = 3000
  health_check_path           = "/health"
  task_cpu                    = 512
  task_memory                 = 1024
  desired_count               = 2
  min_capacity                = 2
  max_capacity                = 4
  secrets                     = module.secrets.ecs_secrets
  tags                        = local.common_tags
}

module "database" {
  source                = "../../modules/database"
  project               = var.project
  env                   = local.env
  vpc_id                = module.networking.vpc_id
  database_subnet_ids   = module.networking.database_subnet_ids
  app_security_group_id = module.compute.app_security_group_id
  instance_class        = "db.t3.small"
  allocated_storage     = 50
  db_name               = var.project
  tags                  = local.common_tags
}

module "storage" {
  source  = "../../modules/storage"
  project = var.project
  env     = local.env
  tags    = local.common_tags
}

module "monitoring" {
  source             = "../../modules/monitoring"
  project            = var.project
  env                = local.env
  alert_emails       = var.alert_emails
  log_retention_days = 14
  ecs_cluster_name   = module.compute.cluster_name
  ecs_service_name   = module.compute.service_name
  rds_identifier     = module.database.identifier
  alb_arn_suffix     = module.compute.alb_arn_suffix
  tags               = local.common_tags
}

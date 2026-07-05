provider "aws" {
  region                      = "us-east-1"
  access_key                  = "mock_key"
  secret_key                  = "mock_secret"
  skip_credentials_validation = true
  skip_requesting_account_id  = true
  skip_metadata_api_check     = true
}

terraform {
  backend "local" { path = "terraform.tfstate" }
}

module "network" {
  source      = "../../modules/network"
  vpc_cidr    = var.vpc_cidr
  environment = "prod"
}

module "ecs" {
  source          = "../../modules/ecs"
  vpc_id          = module.network.vpc_id
  public_subnets  = module.network.public_subnets
  private_subnets = module.network.private_subnets
  environment     = "prod"
}

module "rds" {
  source                = "../../modules/rds"
  vpc_id                = module.network.vpc_id
  private_subnets       = module.network.private_subnets
  ecs_sg_id             = module.ecs.ecs_sg_id
  instance_class        = var.rds_instance_class
  backup_retention_days = var.rds_backup_retention
  deletion_protection   = var.rds_deletion_protection
  environment           = "prod"
}

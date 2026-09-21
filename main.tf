terraform {
  required_version = ">= 1.5.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

data "aws_availability_zones" "available" {
  state = "available"
}

module "networking" {
  source     = "./modules/networking"
  name       = var.project_name
  vpc_cidr   = var.vpc_cidr
  azs        = slice(data.aws_availability_zones.available.names, 0, 2)
  subnet_cidrs = var.public_subnet_cidrs
}

module "rds" {
  source              = "./modules/rds"
  name                = var.project_name
  subnet_ids          = module.networking.public_subnet_ids
  security_group_id   = module.networking.database_security_group_id
  db_name             = var.db_name
  db_username         = var.db_username
  db_password         = var.db_password
}

module "ec2" {
  source            = "./modules/ec2"
  name              = var.project_name
  subnet_id         = module.networking.public_subnet_ids[0]
  security_group_id = module.networking.web_security_group_id
  instance_type     = var.instance_type
  user_data = templatefile("${path.module}/install_wordpress.sh", {
    db_host     = module.rds.endpoint
    db_name     = var.db_name
    db_username = var.db_username
    db_password = var.db_password
  })
}

module "ebs" {
  source            = "./modules/ebs"
  name              = var.project_name
  availability_zone = module.ec2.availability_zone
  instance_id       = module.ec2.instance_id
  size              = 10
}


provider "aws" {
  region = var.aws_region
}

module "vpc" {
  source     = "./modules/vpc"
  project    = var.project
  cidr_block = var.vpc_cidr
}

module "security" {
  source      = "./modules/security"
  project     = var.project
  vpc_id      = module.vpc.vpc_id
  allowed_ips = var.allowed_ips
}

module "ec2" {
  source                 = "./modules/ec2"
  project                = var.project
  vpc_id                 = module.vpc.vpc_id
  subnet_id              = module.vpc.public_subnet_ids[0]
  security_group_id      = module.security.security_group_id
  instance_type          = var.instance_type
  key_name               = var.key_name
  associate_public_ip    = true
  depends_on             = [module.vpc, module.security]
}
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.8.0"
    }
  }
  backend "s3" {
    bucket = "yagr-tf-state-log"
    key    = "event/eks-demo"
    region = "us-east-1"
  }
}

module "networks" {
  source                   = "./modules/networks"
  az0                      = "us-east-1a"
  az1                      = "us-east-1b"
}

module "iam" {
  source                   = "./modules/iam"
  eks_role_name            = "app_cluster_role"
}

module "eks" {
  source                   = "./modules/eks"
  cluster_name             = "demo_cluster"
  cluster_version          = "1.21"
  # vpc_id                   = module.networks.main_vpc_id
  subnet_ids               = [module.networks.app_private_subnet0_id, module.networks.app_private_subnet1_id]
  node_group_name          = "demo_node_group"
  node_group_desired_size  = 3
  node_group_max_size      = 6
}



# main_vpc_id              = module.networks.main_vpc_id
# app_public_subnet_id     = module.networks.app_public_subnet_id
# app_private_subnet_id    = module.networks.app_private_subnet_id



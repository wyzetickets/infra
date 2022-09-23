terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.0"
    }
  }
}

# Configure the AWS Provider
provider "aws" {
  region = "us-east-2"
}

module "sns" {
  source = "./sns"
}

module "rds" {
  source = "./rds"
  vpc_id = module.vpc.vpc_id
  database_subnet_group_name = module.vpc.database_subnet_group_name
  sns_arn = module.sns.arn
  # subnet-0fbaa291fb3c8b37a
}
terraform {
  required_version = "~> 1"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5"
    }
  }

  # backend "s3" {
  #   bucket = "fxc-main-terraform"
  #   key    = "tfstate/global/devops-task/terraform.tfstate"
  #   region = var.region
  # }
}

provider "aws" {
  region = var.region
  default_tags {
    tags = local.common_tags
  }
}

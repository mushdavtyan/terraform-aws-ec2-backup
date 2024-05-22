
locals {
  module_path = abspath(path.module)
  common_tags = tomap({
    "FXC:Maintainer"  = "Mushegh Davtyan",
    "FXC:environment" = "fxctest",
    "FXC:project"     = "FXC-Intelligence-Take-Home-Task-DevOps",
    "Created-by"      = "Terraform"
  })
}

variable "instance_type" {
  description = "The instance type to be used"
  type        = string
  default     = "t2.micro"
}

variable "region" {
  type    = string
  default = "eu-west-2"
}

variable "sg_tag_name" {
  description = "The Name to apply to the security group"
  type        = string
  default     = "SG-created-by-terraform"
}

variable "bucket_name" {
  description = "The name of the S3 bucket"
  type        = string
}

variable "fxctest_vpc_cidr" {
  default = "172.172.0.0/16"
}

variable "ssh_key_name" {
  description = "The name of the SSH key to use"
  type        = string
}

variable "backup_folder_path" {
  description = "The path to the backup folder"
  type        = string
}

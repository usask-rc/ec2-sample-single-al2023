# Variable definitions. Do not put values in here, they go in *.auto.tfvars files

variable "public_key" {
  type        = string
  description = "Path to the public ssh key for instances in this environment"
}

variable "tfstate_bucket_name" {
  description = "The name of the S3 bucket to store terraform state"
  type        = string
}

variable "environment_name" {
  description = "The name of this environment"
  type        = string
}

variable "ec2_web_name" {
  description = "The name for the EC2 web instance"
  type        = string
}

variable "vpc_id" {
  description = "The id of the VPC already existing"
  type        = string
}

variable "instance_type" {
  description = "The EC2 instance type"
  type        = string
}

variable "ec2_instance_profile" {
  description = "The IAM instance profile to use when creating EC2 instance"
  type        = string
}

variable "subnet_id" {
  description = "The id of the public subnet already existing"
  type        = string
}

variable "deploy_region" {
  description = "The AWS region to deploy into"
  type        = string
}

variable "deploy_zone" {
  description = "The availability zone within the deploy region"
  type        = string
}

variable "security_base_ingress_rules" {
  type = list(object({
    cidr_ipv4   = string
    from_port   = string
    to_port     = string
    description = string
  }))
}

variable "security_base_egress_rules" {
  type = list(object({
    cidr_ipv4   = string
    from_port   = string
    to_port     = string
    description = string
    ip_protocol = string
  }))
}

variable "security_frontend_ingress_rules" {
  type = list(object({
    cidr_ipv4   = string
    from_port   = string
    to_port     = string
    description = string
  }))
}

data "aws_ebs_volumes" "volume_list" {
  filter {
    name   = "tag:Name"
    values = ["*"]
  }
}

data "aws_ebs_volume" "volume_ids" {
  for_each = toset(data.aws_ebs_volumes.volume_list.ids)
  filter {
    name   = "volume-id"
    values = [each.value]
  }
}



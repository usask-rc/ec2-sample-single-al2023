#Define Terrraform Providers and Backend
terraform {
  required_version = "> 1.5"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  backend "s3" {
    bucket       = "ansible-tfstate-ec2-sample" # This value must match what is in environment.auto.tfvars
    key          = "ec2-sample"   # vars not allowed here!
    region       = "ca-central-1" # vars not allowed here!
    encrypt      = true
    use_lockfile = true # S3 native locking, no DynamoDB needed
  }

}

# Default provider: AWS
provider "aws" {
  region = "ca-central-1"
  default_tags {
    tags = {
      Environment = var.environment_name
      Terraform   = "True"
    }
  }
}

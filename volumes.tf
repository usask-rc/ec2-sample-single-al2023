# https://docs.aws.amazon.com/ebs/latest/userguide/ebs-volume-types.html
# gp3 volume type is preferred for most cases
# io2 volume type is 50% more expensive than gp3 but delivers 100x fewer failure rates
# Minimum size for gp3 is 1 GiB, minimum size for io2 is 4 GiB

# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ebs_volume.html
# When selecting io2 type, iops must also be specified

# EBS volume for web:/etc/letsencrypt
resource "aws_ebs_volume" "web_etc_letsencrypt" {
  availability_zone = var.deploy_zone
  encrypted = true
  size              = 1
  type              = "gp3"
  tags = {
    Name = "web_etc_letsencrypt"
  }
}

# EBS volume for web:/var/www/
resource "aws_ebs_volume" "web_var_www" {
  availability_zone = var.deploy_zone
  encrypted = true
  size              = 5
  type              = "gp3"
  tags = {
    Name = "web_var_www"
  }
}

# Find the latest AMI for Amazon Linux 2023
data "aws_ami" "al2023" {
  most_recent = true
  owners      = ["amazon"]
  name_regex  = "^al2023-ami-2023"

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  filter {
    name   = "block-device-mapping.volume-type"
    values = ["gp3"]
  }
}

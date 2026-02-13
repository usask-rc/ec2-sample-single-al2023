# EIP for web
resource "aws_eip" "web" {
  domain = "vpc"
  tags = {
    Name = var.ec2_web_name
  }
}

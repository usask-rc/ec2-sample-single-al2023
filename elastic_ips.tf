# Elastic IP (EIP - public IP address) for web instance
resource "aws_eip" "web" {
  domain = "vpc"
  tags = {
    Name = var.ec2_web_name
  }
}

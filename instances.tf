# EC2 instance for front end
resource "aws_instance" "web" {
  ami                    = data.aws_ami.al2023.id
  instance_type          = var.instance_type
  subnet_id              = var.subnet_id
  key_name               = "sample-user"
  iam_instance_profile   = var.ec2_instance_profile
  vpc_security_group_ids = [aws_security_group.sample-sg-base-ec2.id, aws_security_group.sample-sg-front-end.id]
  user_data              = file("scripts/bootstrap_web.sh")
  tags = {
    "Name"         = var.ec2_web_name
    "private_name" = var.ec2_web_name
    "public_name"  = "www"
    "app"          = "sample"
    "environment"  = var.environment_name
  }
}

# Associate EIP to Web instance
resource "aws_eip_association" "eip_web" {
  instance_id   = aws_instance.web.id
  allocation_id = aws_eip.web.id
}

# These device names will be renamed by AWS into /dev/nvme[0-9]n1 randomly
# see: https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/device_naming.html
# On Amazon Linux 2023, there will be symlinks from device_name into the renamed device

# web:/etc/letsencrypt
resource "aws_volume_attachment" "attach_web_etc_letsencrypt" {
  volume_id   = aws_ebs_volume.web_etc_letsencrypt.id
  instance_id = aws_instance.web.id
  device_name = "/dev/sdf"
}

# web:/var/www
resource "aws_volume_attachment" "attach_web_var_www" {
  volume_id   = aws_ebs_volume.web_var_www.id
  instance_id = aws_instance.web.id
  device_name = "/dev/sdg"
}

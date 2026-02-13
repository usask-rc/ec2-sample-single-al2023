# Create a base security group to be assigned to all EC2 instances
resource "aws_security_group" "sample-sg-base-ec2" {
  name   = "sample-sg-base-ec2"
  vpc_id = var.vpc_id
}

# Base EC2 ingress rules
resource "aws_vpc_security_group_ingress_rule" "sample-sr-ec2-base-ingress" {
  for_each          = { for k, v in var.security_base_ingress_rules : k => v }
  security_group_id = aws_security_group.sample-sg-base-ec2.id
  from_port         = each.value.from_port
  to_port           = each.value.to_port
  cidr_ipv4         = each.value.cidr_ipv4
  description       = each.value.description
  ip_protocol       = "tcp"
}

# Base EC2 egress rules
resource "aws_vpc_security_group_egress_rule" "sample-sr-ec2-base-egress" {
  for_each          = { for k, v in var.security_base_egress_rules : k => v }
  security_group_id = aws_security_group.sample-sg-base-ec2.id
  from_port         = each.value.from_port
  to_port           = each.value.to_port
  cidr_ipv4         = each.value.cidr_ipv4
  description       = each.value.description
  ip_protocol       = each.value.ip_protocol
}

# Create a Security Group for the Front end Server
resource "aws_security_group" "sample-sg-front-end" {
  name   = "sample-sg-front-end"
  vpc_id = var.vpc_id
}

# Front End EC2 ingress rules
resource "aws_vpc_security_group_ingress_rule" "sample-sr-ec2-frontend-ingress" {
  for_each          = { for k, v in var.security_frontend_ingress_rules : k => v }
  security_group_id = aws_security_group.sample-sg-front-end.id
  from_port         = each.value.from_port
  to_port           = each.value.to_port
  cidr_ipv4         = each.value.cidr_ipv4
  description       = each.value.description
  ip_protocol       = "tcp"
}



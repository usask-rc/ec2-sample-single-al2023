security_base_egress_rules = [
  {
    cidr_ipv4   = "0.0.0.0/0"
    from_port   = "0"
    to_port     = "65535"
    ip_protocol = "tcp"
    description = "Allow all outbound TCP traffic"
  },
  {
    cidr_ipv4   = "0.0.0.0/0"
    from_port   = "0"
    to_port     = "65535"
    ip_protocol = "udp"
    description = "Allow all outbound UDP traffic"
  },
  {
    cidr_ipv4   = "0.0.0.0/0"
    from_port   = "-1"
    to_port     = "-1"
    ip_protocol = "icmp"
    description = "Allow all outbound ICMP traffic"
  }
]

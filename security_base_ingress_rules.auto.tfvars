# Base ingress rules are applied to front end and back end instances
security_base_ingress_rules = [{
  cidr_ipv4   = "0.0.0.0/0"
  from_port   = "80"
  to_port     = "80"
  description = "http-public"
  },
  {
    cidr_ipv4   = "0.0.0.0/0"
    from_port   = "443"
    to_port     = "443"
    description = "https-public"
  },
  {
    cidr_ipv4   = "128.233.0.0/16"
    from_port   = "22"
    to_port     = "22"
    description = "ssh-usask-campus"
  }
]

security_frontend_ingress_rules = [
  {
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
  }
]

# Local path to the ed25519 ssh public key that will be injected to EC2 instances
public_key = "~/.ssh/ec2sample.pub"

# A short name for this environment
environment_name = "ec2sample"

# The host name for web
ec2_web_name = "web"

# The VPC and subnet to deploy into
vpc_id    = ""
subnet_id = ""

# t2.micro = 1 VCPU / 1 GB RAM / x86_64
# t3.micro = 2 VCPU / 1 GB RAM / x86_64
# t3.micro = 2 VCPU / 2 GB RAM / x86_64
# t3.medium = 2 VCPU / 4 GB RAM / x86_64
instance_type = "t2.micro"
ec2_instance_profile = "DefaultEC2InstanceProfile"

deploy_region       = "ca-central-1"
deploy_zone         = "ca-central-1a"
tfstate_bucket_name = ""
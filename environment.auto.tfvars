# Local path to the ed25519 ssh public key that will be injected to EC2 instances
# You should have already created this key by following the readme
public_key = "~/.ssh/ec2sample.pub"

# A short name for this environment
environment_name = "ec2sample"

# The host name for the web instance
ec2_web_name = "web"

# The VPC and subnet to deploy into; copy these values from the VPC in your account
vpc_id    = ""
subnet_id = ""

# t2.micro = 1 VCPU / 1 GB RAM / x86_64
# t3.micro = 2 VCPU / 1 GB RAM / x86_64
# t3.micro = 2 VCPU / 2 GB RAM / x86_64
# t3.medium = 2 VCPU / 4 GB RAM / x86_64
instance_type = "t2.micro"

# This instance profile should already be in your Usask AWS account
ec2_instance_profile = "DefaultEC2InstanceProfile"

# The Usask AWS organization is region-limited to Canada
deploy_region       = "ca-central-1"
deploy_zone         = "ca-central-1a"

# This value must match what is in provider.tf
tfstate_bucket_name = ""
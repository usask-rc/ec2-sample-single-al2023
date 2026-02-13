# ec2-sample-single-al2023

Sample terraform project to create a single EC2 instance with a public IP running Amazon Linux 2023.

This repository is intended for University of Saskatchewan researchers deploying to a member AWS account within the Usask AWS organization, it may not work in your environment.  Please note that if you deploy the resources in this repository into your AWS account **you will start to incur charges**. You are encouraged to destroy the resources when you are done testing so that the charges do not continue to accumulate.

1. Download and install the needed tools:

Terraform: https://developer.hashicorp.com/terraform/install

AWS CLI: https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html

2. Configure SSO
```
aws configure sso --profile <profilename>
```

3. Log in to AWS CLI
```
aws sso login --profile <profilename>
```
Also run the following command so that terraform uses the correct profile:
```
export AWS_PROFILE="<profilename>"
```

4. Choose an S3 bucket name

Since S3 bucket names are globally unique, do not use "ansible-tfstate-ec2-sample"... choose a new name that contains something unique.

5. Put the S3 bucket name in the provider file

Edit the file `provider.tf` and replace the value for backend s3 -> bucket. Sadly, we cannot use variables here.

6. Create an S3 bucket to store the terraform state

Use your chosen bucket name here, and the `--profile` argument is required if you aren't using the default AWS profile.

If you forget the `--create-bucket-configuration` argument you will get an error "The unspecified location constraint is incompatible for the region specific endpoint this request was sent to."  This argument is required to create a bucket that is constrained to the `ca-central-1` region.

```
aws s3api create-bucket --bucket <bucketname> \
  --region ca-central-1 \
  --create-bucket-configuration LocationConstraint=ca-central-1 \
  --profile <profilename>
```

7. Create an ed25519 key for your instance

When prompted for a file name use `~/.ssh/ec2sample`.  You should end up with two files `~/.ssh/ec2sample` and `~/.ssh/ec2sample.pub`.  You cannot use an RSA key because the latest versions of ssh on linux will no longer accept RSA keys by default.

```
ssh-keygen -t ed25519 -C "your.email@example.com"
```

8. Populate variables for your environment

Edit the file `environment.auto.tfvars` Ensure that you already have an internet gateway in the VPC, and also ensure that you select a public subnet.

9. Initialize Terraform

```
terraform init
```

10. Show the Terraform plan

```
terraform plan
```

11. Apply the plan

If eveything looks OK in the plan, apply it.

```
terraform apply
```
After applying, run terraform apply again to ensure that the deployed infrastructure matches the desired state (some times the EBS volumes take longer to create than terraform waits):
```
terraform apply
```
Now you can go look at the objects in the AWS web console.  If you click on the instance and open AWS SSM console, you will get a terminal into the instance without opening up ssh port 22.

If you want to ssh into your newly created instance, first edit the file `security_base_ingress_rules.auto.tfvars` and add your IP address as needed.  The U of S campus address space is already there for convenience. Next, check both the security group rule for port 22 inbound and also the subnet NACL for port 22 inbound, they will likely both need to be added.  Do not open port 22 to the world - just add your IP address. If you are not sure, you can go to https://whatsmyip.com/ and find what it is.

12. Clean up

If you are done with this example, you can ask Terraform to remove all created objects.

```
terraform destroy
```

In more advanced projects there will be objects that have a life cycle defined and cannot be destroyed, but in this example everything can be destroyed.

Note: if you copy this repo and use it as the basis for a new project, you may want to remove the file `elastic_ips.tf` and create your elastic IPs manually, so that terraform will not destroy them.  In this case you will want to define new variables for the elastic IP IDs. You could also use a lifecycle property within the aws_eip definition, you will then only be able to perform targeted resource deletion instead of complete project deletion.


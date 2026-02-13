output "ec2_ids" {
  description = "List of EC2 instance names and ids"
  value = {
    for instance in [aws_instance.web] :
    instance.tags.Name => instance.id
  }
}

output "private_ips" {
  description = "List of private IP addresses assigned to web"
  value = {
    for instance in [aws_instance.web] :
    instance.tags.Name => instance.private_ip
  }
}

output "elastic_ips" {
  description = "List of public IP addresses assigned to web"
  value       = { for i in [aws_eip.web] : i.tags.Name => "${i.id} => ${i.public_ip}" }
}

output "volumes" {
  value = { for s in data.aws_ebs_volume.volume_ids : s.tags.Name => s.id }
}

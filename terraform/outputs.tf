output "vpc_id" {
  description = "ID of the VPC"
  value       = module.vpc.vpc_id
}

output "ec2_instance_id" {
  description = "ID of the EC2 instance"
  value       = module.ec2.instance_id
}

output "ec2_public_ip" {
  description = "Public IP address of the EC2 instance"
  value       = module.ec2.public_ip
}

output "application_url" {
  description = "URL to access the application"
  value       = "http://${module.ec2.public_ip}"
}

output "grafana_url" {
  description = "URL to access Grafana dashboard"
  value       = "http://${module.ec2.public_ip}:3000"
}

output "prometheus_url" {
  description = "URL to access Prometheus"
  value       = "http://${module.ec2.public_ip}:9090"
}
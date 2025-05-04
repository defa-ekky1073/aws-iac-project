variable "aws_region" {
  description = "AWS region to deploy resources"
  type        = string
  default     = "us-east-1"
}

variable "project" {
  description = "Project name for tagging resources"
  type        = string
  default     = "aws-iac-project"
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "allowed_ips" {
  description = "List of IPs allowed to connect to the EC2 instance"
  type        = list(string)
  default     = ["0.0.0.0/0"] # For production, restrict to specific IPs
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t2.micro"
}

variable "key_name" {
  description = "Name of the SSH key pair to use for EC2 instances"
  type        = string
  default     = "aws-iac-key"
}
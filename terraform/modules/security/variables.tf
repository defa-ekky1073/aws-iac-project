variable "project" {
  description = "Project name for tagging"
  type        = string
}

variable "vpc_id" {
  description = "VPC ID for security group"
  type        = string
}

variable "vpc_cidr" {
  description = "VPC CIDR block for internal access rules"
  type        = string
  default     = "10.0.0.0/16"
}

variable "allowed_ips" {
  description = "List of allowed IP addresses"
  type        = list(string)
  default     = ["0.0.0.0/0"]
}
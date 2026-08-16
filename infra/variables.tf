variable "project_name" {
  description = "Project name used to prefix all resources"
  type        = string
}

variable "ssh_public_key" {
  description = "SSH public key for EC2 key pair"
  type        = string
}

variable "aws_region" {
  description = "AWS region to deploy into"
  type        = string
  default     = "us-east-1"
}

variable "instance_type" {
  description = "EC2 instance type for the Vault server"
  type        = string
  default     = "t3.small"
}

variable "ami_owner" {
  description = "Owner ID of the Ubuntu AMI"
  type        = string
  default     = "099720109477" # Canonical
}

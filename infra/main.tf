data "aws_vpc" "default" {
  default = true
}

data "aws_subnets" "default" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
}

# Latest Ubuntu 22.04 LTS AMI
data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = [var.ami_owner]

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

# EC2 Key Pair
resource "aws_key_pair" "vault" {
  key_name   = "${var.project_name}-vault-key"
  public_key = var.ssh_public_key

  tags = {
    Project   = var.project_name
    ManagedBy = "udap"
  }
}

# Security Group
resource "aws_security_group" "vault" {
  name        = "${var.project_name}-vault-sg"
  description = "Security group for HashiCorp Vault EC2 instance"
  vpc_id      = data.aws_vpc.default.id

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTPS"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "Allow all outbound"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name      = "${var.project_name}-vault-sg"
    Project   = var.project_name
    ManagedBy = "udap"
  }
}

# EC2 Instance
resource "aws_instance" "vault" {
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = var.instance_type
  key_name               = aws_key_pair.vault.key_name
  vpc_security_group_ids = [aws_security_group.vault.id]
  subnet_id              = data.aws_subnets.default.ids[0]

  root_block_device {
    volume_size           = 20
    volume_type           = "gp3"
    delete_on_termination = true
    encrypted             = true
  }

  user_data = <<-EOF
    #!/bin/bash
    apt-get update -y
    apt-get install -y curl
  EOF

  tags = {
    Name      = "${var.project_name}-vault"
    Project   = var.project_name
    ManagedBy = "udap"
  }
}

# Elastic IP
resource "aws_eip" "vault" {
  instance = aws_instance.vault.id
  domain   = "vpc"

  tags = {
    Name      = "${var.project_name}-vault-eip"
    Project   = var.project_name
    ManagedBy = "udap"
  }
}

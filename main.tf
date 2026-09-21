terraform {
  required_version = ">= 1.0.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

# Data Block 1: Dynamic AMI lookup for latest Amazon Linux 2 (No hardcoded AMI ID)
data "aws_ami" "latest_amazon_linux" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }
}

# Data Block 2: Dynamic Default VPC lookup (No hardcoded vpc-id)
data "aws_vpc" "default" {
  default = true
}

# Data Block 3: Dynamic Availability Zones lookup
data "aws_availability_zones" "available" {
  state = "available"
}

# Data Block 4: Dynamic Subnets lookup inside Default VPC (No hardcoded subnet-id)
data "aws_subnets" "default" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
}

# Resource 1: Security Group
resource "aws_security_group" "web_sg" {
  name        = "${var.project_name}-${terraform.workspace}-sg"
  description = "Security Group for ${terraform.workspace} environment"
  vpc_id      = data.aws_vpc.default.id

  ingress {
    description = "Allow HTTP inbound"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "Allow all outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(
    var.common_tags,
    {
      Name        = "${var.project_name}-${terraform.workspace}-sg"
      Environment = terraform.workspace
    }
  )
}

# Resource 2: EC2 Instances (Multi-count based on workspace/tfvars)
resource "aws_instance" "web_server" {
  count         = var.instance_count
  ami           = data.aws_ami.latest_amazon_linux.id
  instance_type = var.instance_type
  subnet_id     = data.aws_subnets.default.ids[0]

  vpc_security_group_ids = [aws_security_group.web_sg.id]

  tags = merge(
    var.common_tags,
    {
      Name        = "${var.project_name}-${terraform.workspace}-ec2-${count.index + 1}"
      Environment = terraform.workspace
      Tier        = var.environment
    }
  )
}

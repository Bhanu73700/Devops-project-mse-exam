variable "aws_region" {
  type        = string
  default     = "us-east-1"
  description = "AWS region for infrastructure deployment"
}

variable "environment" {
  type        = string
  description = "Target deployment environment (dev or prod)"
}

variable "project_name" {
  type        = string
  default     = "multi-env-app"
  description = "Name of the project"
}

variable "instance_type" {
  type        = string
  description = "EC2 instance family and size"
}

variable "instance_count" {
  type        = number
  description = "Number of EC2 instances to provision"
}

variable "common_tags" {
  type        = map(string)
  default     = {
    ManagedBy = "Terraform"
    Project   = "Multi-Env-Challenge"
  }
  description = "Common tags applied to all resources"
}

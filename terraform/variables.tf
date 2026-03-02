# The AWS region to deploy in
variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

# VPC CIDR block
variable "vpc_cidr" {
  description = "VPC CIDR range"
  type        = string
  default     = "10.0.0.0/16"
}

# Project name for tagging
variable "project_name" {
  description = "Name of the project"
  type        = string
  default     = "ofek-status-page"
}

# Database credentials (No default value - security best practice!)
variable "db_password" {
  description = "RDS master password"
  type        = string
  sensitive   = true
}
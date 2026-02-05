variable "aws_region" {
  description = "AWS region for resources"
  type        = string
  default     = "us-east-1"
}

variable "environment" {
  description = "Environment name"
  type        = string
  default     = "staging"
}

variable "project_name" {
  description = "Project name used for resource naming"
  type        = string
  default     = "infra-test"
}

variable "app_config" {
  description = "Application configuration key-value pairs stored in SSM"
  type        = map(string)
  default = {
    "log-level"   = "debug"
    "api-version" = "v1"
    "feature-x"   = "enabled"
  }
}

# ------------------------------------------------------------------------------
# VPC Variables
# ------------------------------------------------------------------------------
variable "vpc_cidr" {
  description = "CIDR block for VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "availability_zones" {
  description = "List of availability zones"
  type        = list(string)
  default     = ["us-east-1a", "us-east-1b"]
}

# ------------------------------------------------------------------------------
# ECS Variables
# ------------------------------------------------------------------------------
variable "container_image" {
  description = "Docker image for the ECS task"
  type        = string
  default     = "nginx:latest"
}

variable "container_cpu" {
  description = "CPU units for the container (1024 = 1 vCPU)"
  type        = number
  default     = 256
}

variable "container_memory" {
  description = "Memory for the container in MB"
  type        = number
  default     = 512
}

variable "container_port" {
  description = "Port the container listens on"
  type        = number
  default     = 80
}

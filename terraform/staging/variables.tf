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

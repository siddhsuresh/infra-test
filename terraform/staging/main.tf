terraform {
  required_version = ">= 1.6.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.aws_region

  default_tags {
    tags = {
      Environment = var.environment
      ManagedBy   = "terraform"
    }
  }
}

resource "aws_ssm_parameter" "test_param_1" {
  name  = "/${var.environment}/test/param1"
  type  = "String"
  value = "test-value-1"
}

resource "aws_ssm_parameter" "test_param_2" {
  name  = "/${var.environment}/test/param2"
  type  = "String"
  value = "test-value-2"
}

output "param1_name" {
  value = aws_ssm_parameter.test_param_1.name
}

output "param2_name" {
  value = aws_ssm_parameter.test_param_2.name
}

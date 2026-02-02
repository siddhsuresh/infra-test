terraform {
  required_version = ">= 1.6.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.0"
    }
  }
}

provider "aws" {
  region = var.aws_region

  default_tags {
    tags = {
      Environment = var.environment
      ManagedBy   = "terraform"
      Project     = "infra-test"
    }
  }
}

# Random suffix for globally unique S3 bucket name
resource "random_id" "bucket_suffix" {
  byte_length = 4
}

# ------------------------------------------------------------------------------
# S3 Bucket - Storage for application data
# ------------------------------------------------------------------------------
resource "aws_s3_bucket" "app_data" {
  bucket = "${var.project_name}-${var.environment}-data-${random_id.bucket_suffix.hex}"

  tags = {
    Name = "${var.project_name}-${var.environment}-data"
  }
}

resource "aws_s3_bucket_versioning" "app_data" {
  bucket = aws_s3_bucket.app_data.id

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_public_access_block" "app_data" {
  bucket = aws_s3_bucket.app_data.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# ------------------------------------------------------------------------------
# DynamoDB Table - Application state storage
# ------------------------------------------------------------------------------
resource "aws_dynamodb_table" "app_state" {
  name         = "${var.project_name}-${var.environment}-state"
  billing_mode = "PAY_PER_REQUEST" # No cost when idle

  hash_key  = "pk"
  range_key = "sk"

  attribute {
    name = "pk"
    type = "S"
  }

  attribute {
    name = "sk"
    type = "S"
  }

  tags = {
    Name = "${var.project_name}-${var.environment}-state"
  }
}

# ------------------------------------------------------------------------------
# SSM Parameters - Application configuration
# ------------------------------------------------------------------------------
resource "aws_ssm_parameter" "app_config" {
  for_each = var.app_config

  name  = "/${var.project_name}/${var.environment}/${each.key}"
  type  = "String"
  value = each.value

  tags = {
    Name = "${var.project_name}-${var.environment}-${each.key}"
  }
}

resource "aws_ssm_parameter" "db_table_name" {
  name  = "/${var.project_name}/${var.environment}/dynamodb-table"
  type  = "String"
  value = aws_dynamodb_table.app_state.name

  tags = {
    Name = "${var.project_name}-${var.environment}-dynamodb-table"
  }
}

resource "aws_ssm_parameter" "s3_bucket_name" {
  name  = "/${var.project_name}/${var.environment}/s3-bucket"
  type  = "String"
  value = aws_s3_bucket.app_data.id

  tags = {
    Name = "${var.project_name}-${var.environment}-s3-bucket"
  }
}

# ------------------------------------------------------------------------------
# Outputs
# ------------------------------------------------------------------------------
output "s3_bucket_name" {
  description = "Name of the S3 bucket"
  value       = aws_s3_bucket.app_data.id
}

output "s3_bucket_arn" {
  description = "ARN of the S3 bucket"
  value       = aws_s3_bucket.app_data.arn
}

output "dynamodb_table_name" {
  description = "Name of the DynamoDB table"
  value       = aws_dynamodb_table.app_state.name
}

output "dynamodb_table_arn" {
  description = "ARN of the DynamoDB table"
  value       = aws_dynamodb_table.app_state.arn
}

output "ssm_parameter_names" {
  description = "Names of SSM parameters"
  value = concat(
    [for k, v in aws_ssm_parameter.app_config : v.name],
    [aws_ssm_parameter.db_table_name.name, aws_ssm_parameter.s3_bucket_name.name]
  )
}

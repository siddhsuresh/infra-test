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
      Project     = "-e2e-test"
    }
  }
}

# Random suffix for unique bucket names
resource "random_id" "bucket_suffix" {
  byte_length = 4
}

# S3 bucket
resource "aws_s3_bucket" "test_bucket" {
  bucket = "s-e2e-test-${var.environment}-${random_id.bucket_suffix.hex}"

  tags = {
    Name = "s E2E Test Bucket - ${var.environment}"
  }
}

resource "aws_s3_bucket_versioning" "test_bucket" {
  bucket = aws_s3_bucket.test_bucket.id
  versioning_configuration {
    status = "Enabled"
  }
}

# Security group
resource "aws_security_group" "test_sg" {
  name        = "s-e2e-test-${var.environment}-${random_id.bucket_suffix.hex}"
  description = "Security group for s E2E testing - ${var.environment}"

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "s E2E Test SG - ${var.environment}"
  }
}

output "bucket_arn" {
  value = aws_s3_bucket.test_bucket.arn
}

output "bucket_name" {
  value = aws_s3_bucket.test_bucket.id
}

output "security_group_id" {
  value = aws_security_group.test_sg.id
}

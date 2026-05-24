terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = "us-east-1"
  # Demo: credentials are set via AWS_ACCESS_KEY_ID / AWS_SECRET_ACCESS_KEY env vars
  skip_credentials_validation = true
  skip_requesting_account_id  = true
  skip_metadata_api_check     = true
  access_key                  = "demo"
  secret_key                  = "demo"
}

# ── S3 buckets ────────────────────────────────────────────────────────────────

# SECURITY ISSUE: public-read ACL (should fail OPA + AI security scan)
resource "aws_s3_bucket" "public_data" {
  bucket = "demo-public-data-bucket"

  tags = {
    Name        = "Public Data"
    Environment = "production"
    Owner       = "platform-team"
  }
}

resource "aws_s3_bucket_acl" "public_data" {
  bucket = aws_s3_bucket.public_data.id
  acl    = "public-read"
}

# OK: private bucket with proper tags
resource "aws_s3_bucket" "app_logs" {
  bucket = "demo-app-logs"

  tags = {
    Name        = "App Logs"
    Environment = "production"
    Owner       = "platform-team"
  }
}

# ── IAM ───────────────────────────────────────────────────────────────────────

# SECURITY ISSUE: IAM user (should use roles + SSO instead)
resource "aws_iam_user" "deploy_bot" {
  name = "deploy-bot"
}

# SECURITY ISSUE: long-lived access key
resource "aws_iam_access_key" "deploy_bot" {
  user = aws_iam_user.deploy_bot.name
}

# OK: IAM role with assume-role policy
resource "aws_iam_role" "app_role" {
  name = "app-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action    = "sts:AssumeRole"
      Effect    = "Allow"
      Principal = { Service = "ec2.amazonaws.com" }
    }]
  })

  tags = {
    Name        = "App Role"
    Environment = "production"
    Owner       = "platform-team"
  }
}

# ── Networking ────────────────────────────────────────────────────────────────

resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"

  tags = {
    Name        = "Main VPC"
    Environment = "production"
    Owner       = "platform-team"
  }
}

# SECURITY ISSUE: open SSH from anywhere
resource "aws_security_group" "web" {
  name   = "web-sg"
  vpc_id = aws_vpc.main.id

  tags = {
    Name        = "Web SG"
    Environment = "production"
    Owner       = "platform-team"
  }
}

resource "aws_security_group_rule" "ssh_open" {
  type              = "ingress"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.web.id
}

# COST ALERT: NAT Gateway (~$32/month)
resource "aws_nat_gateway" "main" {
  allocation_id = aws_eip.nat.id
  subnet_id     = aws_subnet.public.id

  tags = {
    Name        = "Main NAT"
    Environment = "production"
    Owner       = "platform-team"
  }
}

resource "aws_eip" "nat" {
  domain = "vpc"

  tags = {
    Name        = "NAT EIP"
    Environment = "production"
    Owner       = "platform-team"
  }
}

resource "aws_subnet" "public" {
  vpc_id     = aws_vpc.main.id
  cidr_block = "10.0.1.0/24"

  tags = {
    Name        = "Public Subnet"
    Environment = "production"
    Owner       = "platform-team"
  }
}

# ── Compute ───────────────────────────────────────────────────────────────────

# SECURITY ISSUE: EBS volume not encrypted
resource "aws_ebs_volume" "data" {
  availability_zone = "us-east-1a"
  size              = 100
  # encrypted = true  <-- missing!

  tags = {
    Name        = "Data Volume"
    Environment = "production"
    Owner       = "platform-team"
  }
}

# COST ALERT: RDS instance
resource "aws_db_instance" "main" {
  identifier        = "main-db"
  engine            = "postgres"
  engine_version    = "15"
  instance_class    = "db.t3.micro"
  allocated_storage = 20
  username          = "admin"
  password          = "change-me-please"
  skip_final_snapshot = true
  storage_encrypted = true

  tags = {
    Name        = "Main DB"
    Environment = "production"
    Owner       = "platform-team"
  }
}




# Partial configuration. The other settings (e.g., bucket, region) will be
# passed in from a file via -backend-config arguments to 'terraform init'
terraform {
    backend "s3" {
        key = "global/s3/terraform.tfstate"
    }
}

provider "aws" {
    region = "us-east-2"
}

resource "aws_s3_bucket" "terraform_state" {
    bucket = "hja22-terraform-up-and-running-state"

    # prevent accidental deletion of this S3 bucket
    lifecycle {
        prevent_destroy = true
    }

    # keep history of state file
    versioning {
        enabled = true
    }

    # enable server-side encryption of bucket
    server_side_encryption_configuration {
        rule {
            apply_server_side_encryption_by_default {
                sse_algorithm = "AES256"
            }
        }
    }
}

resource "aws_dynamodb_table" "terraform_state_locks" {
    name = "terraform-up-and-running-state-locks"
    billing_mode = "PAY_PER_REQUEST"
    hash_key = "LockID"

    attribute {
        name = "LockID"
        type = "S"
    }
}

output "s3_bucket_arn" {
    value = aws_s3_bucket.terraform_state.arn
    description = "The ARN of the S3 buckets"
}

output "dynamodb_table_name" {
    value = aws_dynamodb_table.terraform_state_locks.name
    description = "The name of the DynamoDB table"
}

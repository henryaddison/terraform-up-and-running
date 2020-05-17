# Partial configuration. The other settings (e.g., bucket, region) will be
# passed in from a file via -backend-config arguments to 'terraform init'
terraform {
    backend "s3" {
        key = "global/iam/terraform.tfstate"
    }
}

provider "aws" {
    region = "us-east-2"
}

resource "aws_iam_user" "example" { 
    for_each = toset(var.user_names)
    name = each.value
}

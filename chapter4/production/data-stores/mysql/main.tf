# Partial configuration. The other settings (e.g., bucket, region) will be
# passed in from a file via -backend-config arguments to 'terraform init'
terraform {
    backend "s3" {
        key = "production/data-stores/mysql/terraform.tfstate"
    }
}

provider "aws" {
    region = "us-east-2"
}

module "database" {
    source = "git@github.com:henryaddison/terraform-up-and-running.git//chapter4/modules/data-stores/mysql?ref=v0.0.2"

    database_identifier_prefix = "terraform-up-and-running-mysql-prod"
    db_master_password_secret_id = "terraform-up-and-running/production/data-stores/mysql/password"
}

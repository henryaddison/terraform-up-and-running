# Partial configuration. The other settings (e.g., bucket, region) will be
# passed in from a file via -backend-config arguments to 'terraform init'
terraform {
    backend "s3" {
        key = "edge/data-stores/mysql/terraform.tfstate"
    }
}

provider "aws" {
    region = "us-east-2"
}

module "database" {
    source = "../../../modules/data-stores/mysql"
    
    database_identifier_prefix = "terraform-up-and-running-mysql-edge"
    db_master_password_secret_id = "terraform-up-and-running/edge/data-stores/mysql/password"
}

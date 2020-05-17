# Partial configuration. The other settings (e.g., bucket, region) will be
# passed in from a file via -backend-config arguments to 'terraform init'
terraform {
    backend "s3" {
        key = "production/servers/terraform.tfstate"
    }
}

provider "aws" {
    region = "us-east-2"
}

module "servers" {
    source = "../../../modules/servers"

    custom_tags = {
        DeployedBy = "terraform"
        Environment = "production"
    }
}

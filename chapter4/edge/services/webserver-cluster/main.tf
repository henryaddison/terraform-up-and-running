# Partial configuration. The other settings (e.g., bucket, region) will be
# passed in from a file via -backend-config arguments to 'terraform init'
terraform {
    backend "s3" {
        key = "edge/services/webserver-cluster/terraform.tfstate"
    }
}

provider "aws" {
    region = "us-east-2"
}

module "webserver_cluster" {
    source = "git@github.com:henryaddison/terraform-up-and-running.git//chapter4/modules/services/webserver-cluster?ref=v0.0.1"

    cluster_name = "webservers-edge"
    db_remote_state_bucket = "hja22-terraform-up-and-running-state"
    db_remote_state_key = "edge/data-stores/mysql/terraform.tfstate"
}

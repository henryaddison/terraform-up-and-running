terraform {
  required_version = "= 0.12.25"
}

provider "aws" {
  region = "us-east-2"

  # Allow any 2.x version of the AWS provider
  version = "~> 2.0"
}

module "hello_world_app" {
    source = "../../../../modules/services/hello-world-app"

    environment = var.environment
    server_text = var.server_text

    min_size = 2
    max_size = 3
    enable_autoscaling = true
}

terraform {
    backend "s3" {
        key = "workspaces-example/terraform.tfstate"
    }
}

provider "aws" {
    region = "us-east-2"
}

resource "aws_instance" "example" {
  ami           = "ami-0c55b159cbfafe1f0"
  instance_type = terraform.workspace == "default" ? "t2.medium" : "t2.micro"
}

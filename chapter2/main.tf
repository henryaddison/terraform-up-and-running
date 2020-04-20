provider "aws" {
    region = "us-east-2"
}

variable "web_server_port" {
    description = "Port on which web server runs"
    type = number
    default = 8080
}


resource "aws_security_group" "example_web_server_sg" {
    name = "terraform-example-web-server-sg"

    ingress {
        from_port = var.web_server_port
        to_port = var.web_server_port
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }
}

resource "aws_instance" "example" {
    ami = "ami-0c55b159cbfafe1f0"
    instance_type = "t2.micro"

    tags = {
        Name = "terraform-example"
    }

    user_data = <<-EOF
        #!/bin/bash
        echo "Hello, world" > index.html
        nohup busybox httpd -f -p ${var.web_server_port} &
    EOF

    vpc_security_group_ids = [aws_security_group.example_web_server_sg.id]
}

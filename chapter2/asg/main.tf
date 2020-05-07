provider "aws" {
    region = "us-east-2"
}

variable "web_server_port" {
    description = "Port on which web server runs"
    type = number
    default = 8080
}

data "aws_vpc" "default" {
  default = true
}

data "aws_subnet_ids" "default" {
    vpc_id = data.aws_vpc.default.id
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

resource "aws_security_group" "example_alb" {
    name = "terraform-example-alb"

    # Allowing incoming HTTP requests
    ingress {
        from_port = 80
        to_port = 80
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    # Allow all outbound requests
    egress {
        from_port = 0
        to_port = 0
        protocol = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }
}

resource "aws_launch_configuration" "example" {
    image_id = "ami-0c55b159cbfafe1f0"
    instance_type = "t2.micro"
    security_groups = [aws_security_group.example_web_server_sg.id]

    

    user_data = <<-EOF
        #!/bin/bash
        echo "Hello, world" > index.html
        nohup busybox httpd -f -p ${var.web_server_port} &
    EOF

    # Required when using a launch configuration with an auto scaling group.
    # https://www.terraform.io/docs/providers/aws/r/launch_configuration.html
    lifecycle {
        create_before_destroy = true
    }
}

resource "aws_autoscaling_group" "example" {
    launch_configuration = aws_launch_configuration.example.name

    target_group_arns = [aws_lb_target_group.asg.arn]
    health_check_type = "ELB"

    min_size = 2
    max_size = 10

    tag {
        key = "Name"
        value = "terraform-asg-example"
        propagate_at_launch = true
    }

    vpc_zone_identifier = data.aws_subnet_ids.default.ids
}

resource "aws_lb" "example" {
    name = "terraform-asg-example"
    load_balancer_type = "application"
    security_groups = [aws_security_group.example_alb.id]
    subnets = data.aws_subnet_ids.default.ids
}

resource "aws_lb_listener" "http" {
    load_balancer_arn = aws_lb.example.arn
    port = 80
    protocol = "HTTP"

    # By default return a simple 404 apge
    default_action {
        type = "fixed-response"

        fixed_response {
            content_type = "text/plain"
            message_body = "404: page not found"
            status_code = 404
        }
    }
}

resource "aws_lb_target_group" "asg" {
    name = "terraform-asg-example"
    port = var.web_server_port
    protocol = "HTTP"
    vpc_id = data.aws_vpc.default.id

    health_check {
        path = "/"
        protocol = "HTTP"
        matcher = "200"
        interval = 15
        timeout = 3
        healthy_threshold = 2
        unhealthy_threshold = 2
    }
}

resource "aws_lb_listener_rule" "asg" {
    listener_arn = aws_lb_listener.http.arn
    priority = 100
    condition {
        path_pattern {
            values = ["*"]
        }
    }

    action {
        type = "forward"
        target_group_arn = aws_lb_target_group.asg.arn
    }
}


output "alb_dns_name" {
    description = "DNS name of the example load balancer"
    value = aws_lb.example.dns_name
}

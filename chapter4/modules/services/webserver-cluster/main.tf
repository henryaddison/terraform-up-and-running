locals {
    http_port    = 80
    any_port     = 0
    any_protocol = "-1"
    tcp_protocol = "tcp"
    all_ips      = ["0.0.0.0/0"]
}

data "aws_vpc" "default" {
  default = true
}

data "aws_subnet_ids" "default" {
    vpc_id = data.aws_vpc.default.id
}

data "terraform_remote_state" "db" {
    backend = "s3"
    config = {
        region = "us-east-2"
        bucket = var.db_remote_state_bucket
        key    = var.db_remote_state_key
    }
}

data "template_file" "user_data" {
    template = file("${path.module}/user_data.sh")

    vars = {
        server_port = var.web_server_port
        db_address  = data.terraform_remote_state.db.outputs.address
        db_port     = data.terraform_remote_state.db.outputs.port
    }
}

resource "aws_security_group" "example_web_server_sg" {
    name = "${var.cluster_name}-sg"

    ingress {
        from_port = var.web_server_port
        to_port = var.web_server_port
        protocol = local.tcp_protocol
        cidr_blocks = local.all_ips
    }
}

resource "aws_security_group" "example_alb" {
    name = "${var.cluster_name}-alb"

    # Allowing incoming HTTP requests
    ingress {
        from_port = local.http_port
        to_port = local.http_port
        protocol = local.tcp_protocol
        cidr_blocks = local.all_ips
    }

    # Allow all outbound requests
    egress {
        from_port = local.any_port
        to_port = local.any_port
        protocol = local.any_protocol
        cidr_blocks = local.all_ips
    }
}

resource "aws_launch_configuration" "example" {
    image_id = "ami-0c55b159cbfafe1f0"
    instance_type = "t2.micro"
    security_groups = [aws_security_group.example_web_server_sg.id]

    user_data = data.template_file.user_data.rendered

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
        value = var.cluster_name
        propagate_at_launch = true
    }

    vpc_zone_identifier = data.aws_subnet_ids.default.ids
}

resource "aws_lb" "example" {
    name = var.cluster_name
    load_balancer_type = "application"
    security_groups = [aws_security_group.example_alb.id]
    subnets = data.aws_subnet_ids.default.ids
}

resource "aws_lb_listener" "http" {
    load_balancer_arn = aws_lb.example.arn
    port = local.http_port
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
    name = var.cluster_name
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

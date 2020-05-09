output "alb_dns_name" {
    description = "DNS name of the example load balancer"
    value = aws_lb.example.dns_name
}

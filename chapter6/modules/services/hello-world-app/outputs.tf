output "alb_dns_name" {
    value = module.alb.alb_dns_name
    description = "Domain name of the load balancer"
}

output "asg_name" {
    value = module.asg.asg_name
}

output "instance_security_group_id" {
  value       = module.asg.instance_security_group_id
  description = "The ID of the EC2 Instance Security Group"
}

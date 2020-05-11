output "address" {
    value = aws_db_instance.example.address
    description = "Endpoint for example MySQL instance"
}

output "port" {
    value = aws_db_instance.example.port
    description = "Port for example MySQL instance"
}

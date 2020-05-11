output "address" {
    value = module.database.address
    description = "Endpoint for example MySQL instance"
}

output "port" {
    value = module.database.port
    description = "Port for example MySQL instance"
}

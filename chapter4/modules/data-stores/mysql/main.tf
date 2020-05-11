data "aws_secretsmanager_secret_version" "db_password" {
    secret_id = var.db_master_password_secret_id
}

resource "aws_db_instance" "example" {
    identifier_prefix = var.database_identifier_prefix
    engine = "mysql"
    allocated_storage = 10
    instance_class = "db.t2.micro"
    name = "example_db"
    username = "admin"
    password = data.aws_secretsmanager_secret_version.db_password.secret_string
    skip_final_snapshot = true
}

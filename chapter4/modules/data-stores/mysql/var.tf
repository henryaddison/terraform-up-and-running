variable "db_master_password_secret_id" {
  description = "The id in AWS Sercret Manager for the database's master password"
  type        = string
}

variable "database_identifier_prefix" {
  description = "The identifier prefix to use for the database resources"
  type        = string
}

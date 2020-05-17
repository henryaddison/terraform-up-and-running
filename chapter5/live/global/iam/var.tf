variable "user_names" {
    description = "List of IAM usernames"
    type = list(string)
    default = ["neo", "morpheus", "trinity"]
}

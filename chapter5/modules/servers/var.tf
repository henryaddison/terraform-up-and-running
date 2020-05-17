variable "custom_tags" {
    description = "Tags for an EC2 instance"
    type = map(string)
    default = {}
}

output "neo_arn" {
    value = aws_iam_user.example["neo"].arn
    description = "The ARN for user Neo"
}

output "all_arns" {
    value = values(aws_iam_user.example)[*].arn
    description = "The ARNs for all users"
}

output "all_users" {
    value = aws_iam_user.example
    description = "All IAM users"
}

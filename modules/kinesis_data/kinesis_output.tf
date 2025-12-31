
output "kinesis_data_role" {
  value = aws_iam_role.firehose_role.name
}

output "kinesis_data_role_arn" {
  value = aws_iam_role.firehose_role.arn
}

output "remote_state_s3_bucket_name" {
  description = "The name of the S3 bucket that stores terraform state file"
  value       =  aws_s3_bucket.terraform_state.bucket
}

output "aws_dynamodb_table" {
  description = "DynamoDB table for terraform lock"
  value       = aws_dynamodb_table.terraform_state_lock.name
}

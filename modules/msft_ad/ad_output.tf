output "directory_id" {
  description = "The ID of the Active directory domeian"
  value       = aws_directory_service_directory.ad_directory.id

}

output "domain_creds_secret" {
  description = "The ARN of the S3 bucket"
  value       = aws_secretsmanager_secret.domain_admin_credentials.id

}
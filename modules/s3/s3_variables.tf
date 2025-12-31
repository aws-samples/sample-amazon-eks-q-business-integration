variable "s3_bucket_name" {
  type        = string
  default     = ""
  description = "S3 Bucket name that will be used as data stores for EKS and Application logs"
}
variable "eks_cluster_arn" {
  type        = string
  default     = ""
  description = "EKS Cluster ARN"
}
variable "vpc_id" {
  type        = string
  default     = ""
  description = "VPC ID for S3 bucket."
}

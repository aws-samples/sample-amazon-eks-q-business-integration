variable "tags" {
  description = "A map of tags to add to all resources"
  type        = map(string)
  default     = {}
}

variable "eks_cluster_role_name" {
  type        = string
  default     = ""
  description = "IAM Role name for the EKS cluster"
}

variable "eks_worker_ng_role_name" {
  type        = string
  default     = ""
  description = "IAM Role name for the EKS Node group"
}

variable "kinesis_data_role" {
  type        = string
  default     = ""
  description = "IAM Role name for Kinesis Data Firehose"
} 

variable "s3_bucket_name" {
  type        = string
  default     = ""
  description = "S3 Bucket name that will store eks logs using kinesis"
}
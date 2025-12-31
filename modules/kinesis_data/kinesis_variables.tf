variable "tags" {
  description = "A map of tags to add to all resources"
  type        = map(string)
  default     = {}
}
variable "kinesis_data_role" {
  type        = string
  default     = ""
  description = "IAM Role name for Kinesis Data Firehose"
} 

variable "eks_cluster_name"{
  type        = string
  default     = ""
  description = "EKS Cluster Name"
}

variable "s3_bucket" {
  type        = string
  default     = ""
  description = "S3 Bucket name that will store eks logs using kinesis"
}

variable "clw_kinesis" {
  type        = string
  default     = ""
  description = "IAM Role name for Kinesis Data Firehose"
}  

variable "kinesis_data_firehose_name" {
  type        = string
  default     = "aws-eks-clw-kinesis-firehose"
  description = "Kinesis Data Firehose name"
}

variable "kinesis_subscription_filter" {
  type        = string
  default     = "aws-eks-clw-kinesis-subscription"
  description = "Kinesis Data Firehose Subscription filter name"
}


variable "aws_eks_cloudwatch_log_group" {
  type        = string
  default     = ""
  description = "AWS EKS CloudWatch Log Group name"
}


variable "tags" {
  description = "A map of tags to add to all resources"
  type        = map(string)
  default     = {}
}

variable "vpc_id" {
  type        = string
  default     = ""
  description = "VPC name to create Amazon Q business in"
}

variable "s3_bucket" {
  type        = string
  default     = ""
  description = "S3 Bucket name that will store eks logs using kinesis"
}

variable "eks_cluster_name"{
  type        = string
  default     = ""
  description = "EKS Cluster Name"
}
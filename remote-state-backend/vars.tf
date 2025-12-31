
############### S3 variables  

variable "s3_backend_bucket_name" {
  type        = string
  default     = "eks-amazonq-tfstate"
  description = "S3 Bucket name that will be used to store terraform backend bucket"

}

############### stack name
variable "stack_name" {
  type        = string
  default     = "eks-amazonq-terraform-stack"
  description = "A name for this stack."
}

############### VPC variables

variable "vpc_name" {
  type        = string
  default     = "amazon-q-vpc"
  description = "VPC name for this stack."
}

variable "region" {
  type        = string
  default     = "us-east-1"
  description = "Region where this stack will be deployed."
}
variable "cidr_block" {
  type        = string
  default     = "10.0.0.0/16"
  description = "The CIDR block for the VPC."
}
variable "availability_zones" {
  default     = ["us-east-1a", "us-east-1b", "us-east-1c"]
  description = "The availability zones to create subnets in"
}

variable "az_counts" {
  default = 3
}
############### EKS variables

variable "eks_name" {
  type        = string
  default     = "eks-cluster"
  description = "A name for this stack."
}
variable "eks_cluster_version" {
  default = "1.30"
}

variable "cw_log_retention" {
  type    = number
  default = "30"
}

############### EKS Node Group variables

variable "node_group_name" {
  type        = string
  default     = "eks-mng"
  description = "EKS managed node group name."
}

variable "node_group_instance_type"{
  type        = string
  default     = "m5.large"
  description = "The instance type of the worker nodes."
}

variable "node_group_desired_size" {
  type        = number
  default     = 3
  description = "The minimum number of instances that will be launched by this group, if not a multiple of the number of AZs in the group, may be rounded up"
}
variable "node_group_max_size" {
  type        = number
  default     = 5
  description = "The minimum number of instances that will be launched by this group, if not a multiple of the number of AZs in the group, may be rounded up"
}

variable "node_group_min_size" {
  type        = number
  default     = 3
  description = "The minimum number of instances that will be launched by this group, if not a multiple of the number of AZs in the group, may be rounded up"
}

############### S3 variables  

variable "s3_bucket_name" {
  type        = string
  default     = "eks-amazonq-business-datastore"
  description = "S3 Bucket name that will be used as data stores for EKS and Application logs"

}

variable "domain_name" {
  type        = string
  default     = "example.com"
  description = "AD Domain Name"
}

variable "kinesis_role" {
  type        = string
  default     = "kinesis-data"
  description = "Kinesis data firehose Role Name"
}

variable "clw_kinesis"{
  type        = string
  default     = "eks-clw-kinesis"
  description = "Cloudwatch to Kinesis firehose Role Name"
}

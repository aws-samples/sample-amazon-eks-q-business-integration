variable "vpc_id" {
  type        = string
  default     = ""
  description = "VPC ID for EKS Cluster."
}

variable "name" {
  type        = string
  default     = "amazonq-eks-mng-1"
  description = "A name for this stack."
}

variable "worker_instance_type" {
  type        = string   
  default     = "[t3.micro, m5.large]"
  description = "The instance type of the worker nodes."
}

variable "legacy_security_groups" {
  type        = bool
  default     = false
  description = "Preserves existing security group setup from pre 1.15 clusters, to allow existing clusters to be upgraded without recreation"
}
variable "cluster_name" {
  type        = string
  default     = ""
  description = "EKS Cluster Name"
}

variable "eks_version" {
  type    = string
  default = "1.30"
}

variable "region" {
  type        = string
  default     = ""
  description = "EKS Cluster Managed Node Group Role_ARN"
}

variable "worker_ng_role_arn" {
  type        = string
  default     = ""
  description = "EKS Cluster Managed Node Group Role_ARN"
}

variable "worker_desired_size" {
  type        = number
  default     = 3
  description = "The minimum number of instances that will be launched by this group, if not a multiple of the number of AZs in the group, may be rounded up"
}
variable "worker_max_size" {
  type        = number
  default     = 5
  description = "The minimum number of instances that will be launched by this group, if not a multiple of the number of AZs in the group, may be rounded up"
}

variable "worker_min_size" {
  type        = number
  default     = 3
  description = "The minimum number of instances that will be launched by this group, if not a multiple of the number of AZs in the group, may be rounded up"
}
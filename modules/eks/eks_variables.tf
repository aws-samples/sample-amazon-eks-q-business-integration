variable "vpc_id" {
  type        = string
  default     = ""
  description = "VPC ID for EKS Cluster."
}

variable "name" {
  type        = string
  default     = "amazonq-eks-cluster"
  description = "Managed node group name."
}

variable "legacy_security_groups" {
  type        = bool
  default     = false
  description = "Preserves existing security group setup from pre 1.15 clusters, to allow existing clusters to be upgraded without recreation"
}

variable "log_retention" {
  type    = string
  default = "30"
}

variable "aws_auth_role_map" {
  type = list(object({
    rolearn  = string
    username = string
    groups   = list(string)
  }))
  default     = []
  description = "A list of mappings from aws role arns to kubernetes users, and their groups"
}

variable "aws_auth_user_map" {
  type = list(object({
    userarn  = string
    username = string
    groups   = list(string)
  }))
  default     = []
  description = "A list of mappings from aws user arns to kubernetes users, and their groups"
}

variable "fstype" {
  type        = string
  default     = "xfs"
  description = "File system type that will be formatted during volume creation, (xfs, ext2, ext3 or ext4)"
}

variable "eks_version" {
  type    = string
  default = "1.30"
}

variable "cluster_role_arn" {
  type        = string
  default     = ""
  description = "EKS Cluster Role_ARN"
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
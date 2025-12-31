variable "name" {
  type        = string
  default     = "example.com"
  description = "AD Domain Name"
}
variable "domain-admin-credentials-secret-name" {
  type        = string
  default     = "eks-amazonq-domain-admin-credential"
  description = "AD Domain Admin Creds"
}

variable "vpc_id" {
  type        = string
  default     = ""
  description = "VPC ID for EKS Cluster."
}
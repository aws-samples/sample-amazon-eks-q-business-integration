
output "vpc_network_id" {
    value = module.vpc.vpc_network_id
}
#output "private_subnet_id" {
#    value = module.vpc.private_subnet_id  
#}
# output "public_subnet_id" {
#    value = module.vpc.public_subnet_id  
#}
#output "eks_cluster_role" {
#  value = module.iam.eks_cluster_role
#}
#output "eks_cluster_role_arn" {
#  value = module.iam.eks_cluster_role_arn
#}
#output "nodegroup_role" {
#  value = module.iam.worker_ng_role
#}

#output "nodegroup_role_arn" {
#  value = module.iam.worker_ng_role_arn
#}

# EKS Specific outputs

#output "cluster_endpoint" {
#  value = module.eks.cluster_endpoint
#}
#output "kubeconfig" {
#  value = module.eks.kubeconfig
#}

output "configure_kubectl" {
    description = "Configure kubectl: make sure you run the following command before using kubectl"
    value = module.eks.configure_kubectl
}
  
output "cluster_name" {
  value = module.eks.cluster_name
}
output "cluster_arn" {
  value = module.eks.eks_cluster_arn
}

#output "eks_cloudwatch_log_group"{
#  value = module.eks.eks_clw_log_group
#}

output "eks_irsa_role_arn" {
  value = module.eks.eks_irsa_role_arn
}

#output "eks_nodegroup_name" {
#  value = module.node_group.node_group_name
#}
#output "aws_auth_role_map" {
#  value = module.node_group.config-map-aws-auth
#}

output "s3_bucket_name" {
  description = "The name of the S3 bucket"
  value       =  module.eks_s3.bucket_name
}

output "bucket_arn" {
  description = "The ARN of the S3 bucket"
  value       = module.eks_s3.bucket_arn
}

output "directory_id" {
  description = "The ID of the Active directory domeian"
  value       = module.msft_ad.directory_id
}

output "domain_creds_secret" {
  description = "The ARN of the S3 bucket"
  value       = module.msft_ad.domain_creds_secret
}
#
#output "kinesis_data_firehose_role" {
#  value = module.kinesis_data.kinesis_data_role
#}

#output "kinesis_data_firehose_role_arn" {
#  value = module.kinesis_data.kinesis_data_role_arn
#}


output "amazonq_business_application" {
  value = module.amazonq_business.amazonq_business_application
}
output "amazonq_business_application_id" {
  value = module.amazonq_business.amazonq_business_application_id
}
output "amazonq_business_datastore" {
  value = module.amazonq_business.amazonq_business_ds
}

output "amazonq_business_ds_name" {
  value = module.amazonq_business.amazonq_business_ds
}

output "amazonq_business_ds_id" {
  value = module.amazonq_business.amazonq_business_ds_id
}

output "amazonq_business_web_url" {
  value = module.amazonq_business.amazonq_business_web_url
}

output "amazonq_business_index_id" {
  value = module.amazonq_business.amazonq_business_index_id
}

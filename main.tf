

//calling the VPC module

module "vpc" {
source               = "./modules/vpc/"
name                 = var.vpc_name
region               = var.region
az_counts            = 3
cidr_block           = var.cidr_block
availability_zones   = var.availability_zones
}

module "iam" {
source                     = "./modules/iam/"
 eks_cluster_role_name    = var.stack_name
 eks_worker_ng_role_name  = var.stack_name

}

//calling the VPC module

module "eks" {
source                    = "./modules/eks/"
name                      = var.eks_name
eks_version               = var.eks_cluster_version
vpc_id                    = module.vpc.vpc_network_id
cluster_role_arn          = module.iam.eks_cluster_role_arn
worker_ng_role_arn        = module.iam.worker_ng_role_arn
log_retention             = var.cw_log_retention
region                    = var.region
worker_desired_size       = var.node_group_desired_size
worker_max_size           = var.node_group_max_size
worker_min_size           = var.node_group_min_size


depends_on = [ module.vpc, module.iam ]
}

//calling the eks node group module

module "node_group" {
source                    = "./modules/eks_node_group/"
name                      = var.node_group_name
eks_version               = var.eks_cluster_version
cluster_name              = module.eks.cluster_name
vpc_id                    = module.vpc.vpc_network_id
worker_ng_role_arn        = module.iam.worker_ng_role_arn
region                    = var.region
worker_instance_type      = var.node_group_instance_type
worker_desired_size       = var.node_group_desired_size
worker_max_size           = var.node_group_max_size
worker_min_size           = var.node_group_min_size

depends_on = [ module.eks, module.vpc, module.iam ]
}

//calling the eks s3 module

module "eks_s3" {
source                    = "./modules/s3/"
s3_bucket_name            = var.s3_bucket_name
eks_cluster_arn           = module.eks.eks_cluster_arn

depends_on = [ module.eks ]
}

//calling microsoft ad modules 
module "kinesis_data" {
source                          = "./modules/kinesis_data/"
kinesis_data_role               = var.kinesis_role
eks_cluster_name                = module.eks.cluster_name
clw_kinesis                     = var.clw_kinesis 
s3_bucket                       = module.eks_s3.bucket_name
aws_eks_cloudwatch_log_group    = module.eks.eks_clw_log_group

depends_on = [ module.eks_s3 ]
}


//calling microsoft ad modules 
module "msft_ad" {
source                    = "./modules/msft_ad/"
name                      = var.domain_name
vpc_id                    = module.vpc.vpc_network_id

depends_on = [ module.vpc ]
}


module "amazonq_business" {
source                          = "./modules/amazonq_business/"
s3_bucket                       = module.eks_s3.bucket_name
eks_cluster_name                = module.eks.cluster_name
vpc_id                          = module.vpc.vpc_network_id


depends_on = [ module.eks_s3, module.msft_ad, module.vpc ]
}


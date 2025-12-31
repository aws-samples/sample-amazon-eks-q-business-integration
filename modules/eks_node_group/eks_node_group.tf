
#######################Addons-node-group

locals {
  worker-mng-name = "${var.name}-mng-worker-${random_string.worker-mng-name.result}"
}

data "aws_ssm_parameter" "eks_ami_release_version" {
  name = "/aws/service/eks/optimized-ami/${var.eks_version}/amazon-linux-2/recommended/release_version"
}

data "aws_subnets" "private" {
    filter {
    name   = "vpc-id"
    values = [var.vpc_id]
  }
  tags = {
    subnet-type = "private"
  }
  depends_on = [var.vpc_id]
}

data "aws_subnets" "public" {
    filter {
    name   = "vpc-id"
    values = [var.vpc_id]
  }
  tags = {
    subnet-type = "public"
  }
depends_on = [var.vpc_id]
}


resource "random_string" "worker-mng-name" {
  length  = 4
  upper   = false
  numeric = true
  lower   = true
  special = false
}

resource "aws_eks_node_group" "worker-node-group" {
  cluster_name    = var.cluster_name
  node_group_name = local.worker-mng-name
  node_role_arn   = var.worker_ng_role_arn
  instance_types  = [var.worker_instance_type]
  subnet_ids      = concat(sort(data.aws_subnets.private.ids))
  release_version = nonsensitive(data.aws_ssm_parameter.eks_ami_release_version.value)


  scaling_config {
    desired_size = var.worker_desired_size
    max_size     = var.worker_max_size
    min_size     = var.worker_min_size

  }

  lifecycle {
    create_before_destroy = false
  }
depends_on = [var.vpc_id , var.cluster_name]
}


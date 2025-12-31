data "aws_subnets" "private" {
  filter {
    name   = "vpc-id"
    values = [var.vpc_id]
  }
  tags = {
    subnet-type = "private"
#    values = ["private"]
  }
depends_on = [var.vpc_id]
}

data "aws_subnets" "public" {
  filter {
    name   = "vpc-id"
    values = [var.vpc_id]
  }
  tags = {
    subnet-type = "private"
  }
depends_on = [var.vpc_id] 
}

resource "aws_security_group" "control_plane" {
  count = var.legacy_security_groups ? 1 : 0

  name        = "eks-control-plane-${var.name}"
  description = "Cluster communication with worker nodes"
  vpc_id      = var.vpc_id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "eks-control-plane-${var.name}"
  }
depends_on = [var.vpc_id]
}

resource "aws_eks_cluster" "cluster" {
  name                      = var.name
  role_arn                  = var.cluster_role_arn
  version                   = var.eks_version
  vpc_config {
    subnet_ids              = concat(sort(data.aws_subnets.private.ids), sort(data.aws_subnets.public.ids))
    security_group_ids      = aws_security_group.control_plane.*.id
    endpoint_private_access = "true"
    endpoint_public_access = "true"
  
  }

  tags = {
    Name = "${var.name}-cluster"
  }
 
  enabled_cluster_log_types = ["api", "audit", "authenticator", "controllerManager", "scheduler" ]
 
  provisioner "local-exec" {
    command     = "until curl --output /dev/null --insecure --silent ${self.endpoint}/healthz; do sleep 1; done"
    working_dir = path.module
  }
depends_on = [ aws_cloudwatch_log_group.cluster, var.vpc_id ]
}

resource "aws_cloudwatch_log_group" "cluster" {
  name              = "/aws/eks/${var.name}/cluster"
  retention_in_days = var.log_retention
}


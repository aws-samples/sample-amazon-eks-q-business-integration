locals {
  bucket_name = "${var.s3_bucket_name}-${data.aws_caller_identity.current.account_id}"
}

data "aws_region" "current" {}
data "aws_caller_identity" "current" {}
/*
resource "random_string" "bucket_name" {
  length  = 4
  upper   = false
  numeric = true
  lower   = true
  special = false
}
*/
resource "aws_s3_bucket" "bucket" {
  bucket                = local.bucket_name
  force_destroy         = true
depends_on = [var.vpc_id]
}

#data "bucket policy" 

resource "aws_s3_bucket_policy" "eks_clw_policy" {
  bucket = aws_s3_bucket.bucket.id
  policy = <<POLICY
{
    "Version": "2012-10-17",
    "Id": "CWLogsPolicy",
    "Statement": [
        {
            "Effect": "Allow",
            "Principal": {
                "Service": [
                    "eks.amazonaws.com",
                    "cloudwatch.amazonaws.com",
                    "logs.${data.aws_region.current.name}.amazonaws.com",
                    "autoscaling.amazonaws.com",
                    "ec2.amazonaws.com"
                ]
            },
            "Action": [
                "s3:PutObject",
                "s3:GetObject"
            ],
            "Resource": [
                "${aws_s3_bucket.bucket.arn}",
                "${aws_s3_bucket.bucket.arn}/*"
            ],
            "Condition": {
                "StringEquals": {
                    "aws:SourceAccount": "${data.aws_caller_identity.current.account_id}"
                },
                "StringLike": {
                    "aws:SourceArn": ["arn:aws:eks:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:cluster/*",
                     "arn:aws:iam:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:role/eks-amazonq-irsa-role"
                     ]
                },
                "ArnEquals": {
                    "aws:SourceArn": "${var.eks_cluster_arn}"
                },
                "ArnLike": {
                    "aws:SourceArn": [
                        "arn:aws:logs:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:*",
                        "arn:aws:autoscaling:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:*",
                        "arn:aws:ec2:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:*"
                    ]
                }
            }
        }
    ]
}
POLICY
}
  


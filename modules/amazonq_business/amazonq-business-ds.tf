
data "aws_region" "current" {}
data "aws_caller_identity" "current" {}

data "aws_s3_bucket" "selected" {
  bucket = "${var.s3_bucket}"
}

data "aws_eks_cluster" "example" {
  name = "${var.eks_cluster_name}"
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
/*
data "aws_subnet" "subnetid" {
  for_each = toset(data.aws_subnets.private.ids)
  id       = each.value
}

locals {
  subnet_arn = [ for subnet in data.aws_subnet.subnetid : subnet.arn ]
}
*/

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

data "aws_security_group" "selected"{
  filter {
    name   = "tag:aws:eks:cluster-name"
    values = ["${var.eks_cluster_name}"]
  }
depends_on = [var.vpc_id]
}

resource "awscc_qbusiness_data_source" "amazonq_ds" {
  application_id = awscc_qbusiness_application.eks_amazonq_int.application_id
  display_name   = "eks_amazonq_data_source"
  index_id       = awscc_qbusiness_index.amazonq_business_indx.index_id
  role_arn       = awscc_iam_role.example.arn
  configuration = jsonencode(
    {
      type     = "S3"
      version  = "1.0.0"
#      syncMode = "FORCED_FULL_CRAWL"
      syncMode = "FULL_CRAWL"
      connectionConfiguration = {
        repositoryEndpointMetadata = {
          BucketName = "${data.aws_s3_bucket.selected.id}"
          #BucketName = aws_s3_bucket.cloudwatch_logs.name
        }
      }
      additionalProperties = {
        inclusionPrefixes = ["${data.aws_eks_cluster.example.name}/", "pod-logs/"]
      }
      vpc_configuration = {
        #subnetIds = local.subnet_arn
        subnetIds = data.aws_subnets.private.ids
        securityGroupIds = [data.aws_security_group.selected.arn]
      }
      repositoryConfigurations = {
        document = {
          fieldMappings = [
            {
              dataSourceFieldName = "s3_document_id"
              indexFieldType      = "STRING"
              indexFieldName      = "s3_document_id"
            }
          ]
        }
      }
    }
  )
  tags = [{
    key   = "Modified By"
    value = "AWSCC"
  }]
depends_on = [var.vpc_id]
}

resource "null_resource" "sync_job" {
    provisioner "local-exec" {
      command = <<EOD
      aws qbusiness start-data-source-sync-job --application-id ${awscc_qbusiness_application.eks_amazonq_int.application_id} --data-source-id ${awscc_qbusiness_data_source.amazonq_ds.data_source_id} --index-id ${awscc_qbusiness_index.amazonq_business_indx.index_id}
  EOD
    }
    depends_on = [ awscc_qbusiness_data_source.amazonq_ds, awscc_qbusiness_index.amazonq_business_indx, awscc_qbusiness_application.eks_amazonq_int ]
}

resource "awscc_iam_role" "example" {
  role_name   = "QBusiness-DataSource-Role"
  description = "QBusiness Data source role"
  assume_role_policy_document = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "AllowsAmazonQToAssumeRoleForServicePrincipal"
        Effect = "Allow"
        Principal = {
          Service = "qbusiness.amazonaws.com"
        }
        Action = [
          "sts:AssumeRole"
        ]
        Condition = {
          StringEquals = {
            "aws:SourceAccount" = data.aws_caller_identity.current.account_id
          },
          ArnLike = {
            "aws:SourceArn" = "arn:aws:qbusiness:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:application/${awscc_qbusiness_application.eks_amazonq_int.id}"
          }
        }
      }
    ]
  })

  tags = [{
    key   = "Modified By"
    value = "AWSCC"
  }]
}

resource "awscc_iam_role_policy" "example" {
  policy_name = "sample_iam_role_policy"
  role_name   = awscc_iam_role.example.id

  policy_document = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = "s3:GetObject"
        Resource = "arn:aws:s3:::${data.aws_s3_bucket.selected.id}/*"
      },
      {
        Effect   = "Allow"
        Action   = "s3:ListBucket"
        Resource = "arn:aws:s3:::${data.aws_s3_bucket.selected.id}"
      },
      {
        Effect = "Allow"
        Action = [
          "qbusiness:BatchPutDocument",
          "qbusiness:BatchDeleteDocument"
        ]
        Resource = [
          "arn:aws:qbusiness:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:application/${awscc_qbusiness_application.eks_amazonq_int.id}",
          "arn:aws:qbusiness:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:application/${awscc_qbusiness_application.eks_amazonq_int.id}/index/${awscc_qbusiness_index.amazonq_business_indx.index_id}"
        ]
      },
      {
        Effect = "Allow"
        Action = [
          "qbusiness:PutGroup",
          "qbusiness:CreateUser",
          "qbusiness:DeleteGroup",
          "qbusiness:UpdateUser",
          "qbusiness:ListGroups"
        ]
        Resource = [
          "arn:aws:qbusiness:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:application/${awscc_qbusiness_application.eks_amazonq_int.id}",
          "arn:aws:qbusiness:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:application/${awscc_qbusiness_application.eks_amazonq_int.id}/index/${awscc_qbusiness_index.amazonq_business_indx.index_id}",
          "arn:aws:qbusiness:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:application/${awscc_qbusiness_application.eks_amazonq_int.id}/index/${awscc_qbusiness_index.amazonq_business_indx.index_id}/data-source/*"
        ]
      },
      {
        Effect = "Allow"
        Action = [
				  "ec2:CreateNetworkInterface",
				  "ec2:DeleteNetworkInterface"
        ]
        Resource = [
        "arn:aws:ec2:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:security-group/*",
        "arn:aws:ec2:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:subnet/*"
        ]
      },
      {
			"Sid": "AllowsAmazonQToCreateDeleteENI",
			"Effect": "Allow",
			"Action": [
				"ec2:CreateNetworkInterface",
				"ec2:DeleteNetworkInterface"
			],
			"Resource": "arn:aws:ec2:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:network-interface/*",
			"Condition": {
				"StringLike": {
					"aws:RequestTag/AMAZON_Q": "qbusiness_${data.aws_caller_identity.current.account_id}_${awscc_qbusiness_application.eks_amazonq_int.id}_*"
				},
				"ForAllValues:StringEquals": {
					"aws:TagKeys": [
						"AMAZON_Q"
					]
				}
			}
		},
		{
			"Sid": "AllowsAmazonQToCreateTags",
			"Effect": "Allow",
			"Action": [
				"ec2:CreateTags"
			],
			"Resource": "arn:aws:ec2:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:network-interface/*",
			"Condition": {
				"StringEquals": {
					"ec2:CreateAction": "CreateNetworkInterface"
				}
			}
		},
		{
			"Sid": "AllowsAmazonQToCreateNetworkInterfacePermission",
			"Effect": "Allow",
			"Action": [
				"ec2:CreateNetworkInterfacePermission"
			],
			"Resource": "arn:aws:ec2:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:network-interface/*",
			"Condition": {
				"StringLike": {
					"aws:ResourceTag/AMAZON_Q": "qbusiness_${data.aws_caller_identity.current.account_id}_${awscc_qbusiness_application.eks_amazonq_int.id}_*"
				}
			}
		},
    {
			"Sid": "AllowsAmazonQToConnectToVPC",
			"Effect": "Allow",
			"Action": [
				"ec2:DescribeNetworkInterfaces",
				"ec2:DescribeAvailabilityZones",
				"ec2:DescribeNetworkInterfaceAttribute",
				"ec2:DescribeVpcs",
				"ec2:DescribeRegions",
				"ec2:DescribeNetworkInterfacePermissions",
				"ec2:DescribeSubnets"
			],
			"Resource": "*"
		}
    ]
  })
}
/*

data "aws_caller_identity" "current" {}

data "aws_region" "current" {}
*/

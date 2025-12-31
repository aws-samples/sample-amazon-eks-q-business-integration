# IAM role that grants CW Permission to put data in FireHose

data "aws_caller_identity" "current" {}


resource "aws_iam_role" "clw_kinesis_role" {
  name = "${var.clw_kinesis}-role"
  depends_on = [ terraform_data.create_kinesis_data_stream ]
 # depends_on = [ null_resource.create_kinesis_data_stream ]
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "logs.amazonaws.com"
      },
     "Action": "sts:AssumeRole",
     "Condition": {
         "StringLike": {
             "aws:SourceArn": "arn:aws:logs:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:*"
         }
      }
    }
  ]

}
EOF
}

# Attach the necessary permissions to the IAM role for the CLWLogs
resource "aws_iam_role_policy" "clw_firehose_policy" {
  name = "clw-firehose-policy"
  role = aws_iam_role.clw_kinesis_role.name

  policy = <<EOF
  {
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "firehose:PutRecord",
        "firehose:PutRecordBatch"
      ],
      "Resource": [
        "arn:aws:firehose:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:deliverystream/${local.data_firhose}"
        ]
    }
  ]
}
EOF
#depends_on = [ null_resource.create_kinesis_data_stream ]
depends_on = [ terraform_data.create_kinesis_data_stream ]
}


resource "aws_cloudwatch_log_subscription_filter" "eks_logs_to_firehose" {
  name            = "${var.kinesis_subscription_filter}"
  log_group_name  = var.aws_eks_cloudwatch_log_group
  role_arn        = aws_iam_role.clw_kinesis_role.arn
  filter_pattern  = ""
#  destination_arn = data.aws_kinesis_firehose_delivery_stream.stream.arn
  destination_arn = "arn:aws:firehose:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:deliverystream/${local.data_firhose}"
#  depends_on      = [null_resource.create_kinesis_data_stream ]
  depends_on = [ terraform_data.create_kinesis_data_stream ]
}
# Create an IAM role for the Firehose delivery stream

resource "aws_iam_role" "firehose_role" {
  name = "${var.kinesis_data_role}-firehose-role"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "firehose.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

# Attach the necessary permissions to the IAM role
resource "aws_iam_role_policy" "firehose_policy" {
  name = "firehose-policy"
  role = aws_iam_role.firehose_role.name

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "s3:AbortMultipartUpload",
        "s3:GetBucketLocation",
        "s3:GetObject",
        "s3:ListBucket",
        "s3:ListBucketMultipartUploads",
        "s3:PutObject"
      ],
      "Resource": [
        "${data.aws_s3_bucket.selected.arn}",
        "${data.aws_s3_bucket.selected.arn}/*"
      ]
    },
    {
      "Effect": "Allow",
      "Action": [
        "logs:DescribeLogGroups",
        "logs:DescribeLogStreams",
        "logs:GetLogEvents"
      ],
      "Resource": [
        "*"
      ]
    }
  ]
}
EOF
}

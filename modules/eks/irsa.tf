resource "aws_iam_role" "default" {
  name = "eks-amazonq-irsa-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Sid    = ""
      Effect = "Allow",
      Principal = {
        Federated = aws_iam_openid_connect_provider.default.arn
      },
      Action = "sts:AssumeRoleWithWebIdentity",
      Condition = {
        StringEquals = {
            "${aws_iam_openid_connect_provider.default.url}:sub" = "system:serviceaccount:default:fluent-bit"
            "${aws_iam_openid_connect_provider.default.url}:aud" = "sts.amazonaws.com"
          }
      }
    }]
  })

  depends_on = [ aws_iam_openid_connect_provider.default ]
}

resource "aws_iam_role_policy" "default" {
  name   = "eks-amazonq-irsa-policy"
  role   = aws_iam_role.default.id
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect = "Allow",
      Action = [
        "firehose:PutRecord",
        "firehose:PutRecordBatch",
        "s3:*"
      ],
      Resource = "*"
    }]
  })
 depends_on = [ aws_iam_openid_connect_provider.default ]

}

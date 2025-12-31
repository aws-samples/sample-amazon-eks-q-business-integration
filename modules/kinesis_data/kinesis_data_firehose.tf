
data "aws_region" "current" {}

locals {
  bucket_arn = "${data.aws_s3_bucket.selected.arn}"
}
data "aws_eks_cluster" "example" {
  name = "${var.eks_cluster_name}"
}

data "aws_s3_bucket" "selected" {
  bucket = "${var.s3_bucket}"
}
locals {
  data_firhose = "${var.kinesis_data_firehose_name}-${data.aws_caller_identity.current.account_id}"
}

resource "terraform_data" "create_kinesis_data_stream" {
    
   input = {
    data_firhose = "${local.data_firhose}"
  }
    provisioner "local-exec" {
      when = create
      command = <<EOD
      while true ; do                                   
              if aws iam get-role --role-name "${aws_iam_role.firehose_role.id}" --region "${data.aws_region.current.name}"
              then
                echo "IAM role ${aws_iam_role.firehose_role.id} created"
                  sleep 45
                  break
              else
                echo "IAM role not found. Retrying in 5 seconds..."
                sleep 5
              fi
        done     
      echo "Creating Firehose '${local.data_firhose}'"
      aws firehose create-delivery-stream \
  --delivery-stream-name "${local.data_firhose}" \
  --delivery-stream-type DirectPut \
  --extended-s3-destination-configuration '{
      "RoleARN": "${aws_iam_role.firehose_role.arn}",
      "BucketARN": "${data.aws_s3_bucket.selected.arn}",
      "Prefix": "${data.aws_eks_cluster.example.name}/",
      "CompressionFormat": "UNCOMPRESSED",
      "ProcessingConfiguration": {
        "Enabled": true,
        "Processors": [{
          "Type": "Decompression",
          "Parameters": [{
            "ParameterName": "CompressionFormat",
            "ParameterValue": "GZIP"
          }]
        }]
      }
    }'
EOD
 
}
 
 provisioner "local-exec" { 

            when    = destroy
#            command = "until aws firehose delete-delivery-stream --delivery-stream-name ${self.input.data_firhose} --allow-force-delete; do sleep 1; done"
            command =  "aws firehose describe-delivery-stream --delivery-stream-name ${self.input.data_firhose} >/dev/null 2>&1 && until aws firehose delete-delivery-stream --delivery-stream-name ${self.input.data_firhose} --allow-force-delete; do sleep 5; done || echo 'Stream does not exist'"

    }

  depends_on = [aws_iam_role.firehose_role, data.aws_s3_bucket.selected]
}

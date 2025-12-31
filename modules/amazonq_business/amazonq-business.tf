resource "awscc_qbusiness_application" "eks_amazonq_int" {
  description                  = " QBusiness Application for Amazon EKS"
  display_name                 = "eks_amazonq_app"
  identity_center_instance_arn = data.aws_ssoadmin_instances.example.arns[0]
  attachments_configuration = {
    attachments_control_mode = "ENABLED"
  }

  tags = [{
    key   = "Modified By"
    value = "AWSCC"
  }]

}

data "aws_ssoadmin_instances" "example" {}
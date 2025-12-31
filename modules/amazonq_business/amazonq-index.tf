resource "awscc_qbusiness_index" "amazonq_business_indx" {
  application_id = awscc_qbusiness_application.eks_amazonq_int.application_id
  display_name   = "eks_amazonq_int_q_index"
  description    = "Example QBusiness Index"
  type           = "ENTERPRISE"
  capacity_configuration = {
    units = 50
  }

  tags = [{
    key   = "Modified By"
    value = "AWSCC"
  }]

}
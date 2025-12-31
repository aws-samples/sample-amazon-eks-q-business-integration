resource "awscc_qbusiness_retriever" "amazonq_business_retr" {
  application_id = awscc_qbusiness_application.eks_amazonq_int.application_id
  display_name   = "amazon_q_retriever"
  type           = "NATIVE_INDEX"

  configuration = {
    native_index_configuration = {
      index_id = awscc_qbusiness_index.amazonq_business_indx.index_id
    }
  }
  tags = [{
    key   = "Modified By"
    value = "AWSCC"
  }]

}

output "amazonq_business_application" {
  #value = awscc_qbusiness_application.eks_amazonq_int.application_id
  value = awscc_qbusiness_application.eks_amazonq_int.display_name  
}

output "amazonq_business_application_id" {
  value = awscc_qbusiness_application.eks_amazonq_int.application_id
}

output "amazonq_business_ds" {
  value = awscc_qbusiness_data_source.amazonq_ds.display_name
}

output "amazonq_business_ds_id" {
  value = awscc_qbusiness_data_source.amazonq_ds.data_source_id
}

output "amazonq_business_ds_name" {
  value = awscc_qbusiness_data_source.amazonq_ds.data_source_id
}


output "amazonq_business_web_url" {
  value = awscc_qbusiness_web_experience.example.default_endpoint
}

output "amazonq_business_index_id" {
  value = awscc_qbusiness_index.amazonq_business_indx.id

}
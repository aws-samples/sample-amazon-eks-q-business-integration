output "eks_cluster_role" {
  value = aws_iam_role.cluster_role.name
}
output "eks_cluster_role_arn" {
  value = aws_iam_role.cluster_role.arn
}
output "worker_ng_role" {
  value = aws_iam_role.managed_workers.name
}

output "worker_ng_role_arn" {
  value = aws_iam_role.managed_workers.arn
}
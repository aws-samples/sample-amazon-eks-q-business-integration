locals {
  config_map_aws_auth = <<CONFIGMAPAWSAUTH
apiVersion: v1
kind: ConfigMap
metadata:
  name: aws-auth
  namespace: kube-system
data:
  mapRoles: |
    - rolearn: ${var.worker_ng_role_arn}
      username: system:node:{{EC2PrivateDNSName}}
      groups:
        - system:bootstrappers
        - system:nodes
CONFIGMAPAWSAUTH

  awskubeconfig = <<KUBECONFIG
apiVersion: v1
clusters:
- cluster:
    server: ${aws_eks_cluster.cluster.endpoint}
    certificate-authority-data: ${aws_eks_cluster.cluster.certificate_authority[0].data}
  name: kubernetes
contexts:
- context:
    cluster: kubernetes
    user: aws
  name: aws
current-context: aws
kind: Config
preferences: {}
users:
- name: aws
  user:
    exec:
      apiVersion: client.authentication.k8s.io/v1beta1
      command: aws-iam-authenticator
      args:
        - "token"
        - "-i"
        - "${aws_eks_cluster.cluster.name}"
KUBECONFIG
}

output "kubeconfig" { value = local.awskubeconfig }

output "configure_kubectl" {
  value = "aws eks --region ${var.region} update-kubeconfig --name ${aws_eks_cluster.cluster.name}"
}

output "cluster_name" {
  value = aws_eks_cluster.cluster.name
}

output "cluster_endpoint" {
  value = aws_eks_cluster.cluster.endpoint
}

output "eks_cluster_arn" {
  value = aws_eks_cluster.cluster.arn
}

output "eks_clw_log_group" {
  value = aws_cloudwatch_log_group.cluster.name
}

output "eks_irsa_role_arn" {
  value = aws_iam_role.default.arn
}
  

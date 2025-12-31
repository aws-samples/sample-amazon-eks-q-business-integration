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
}

output "config-map-aws-auth" { value = local.config_map_aws_auth }


output "node_group_name" {
  value = aws_eks_node_group.worker-node-group.node_group_name
}

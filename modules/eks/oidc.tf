data "aws_eks_cluster" "default" {
  name = aws_eks_cluster.cluster.name
  depends_on = [aws_eks_cluster.cluster]
}

data "tls_certificate" "default" {
  url = data.aws_eks_cluster.default.identity[0].oidc[0].issuer
}

resource "aws_iam_openid_connect_provider" "default" {
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = [data.tls_certificate.default.certificates[0].sha1_fingerprint]
  url             = data.tls_certificate.default.url
  depends_on = [ aws_eks_cluster.cluster ]
}
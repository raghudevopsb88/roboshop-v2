# Ensures AWS finishes deleting the cluster and releases ENIs before VPC teardown.
resource "null_resource" "eks_destroy_wait" {
  triggers = {
    cluster_name = aws_eks_cluster.main.name
    region       = data.aws_region.current.name
  }

  depends_on = [
    aws_eks_cluster.main,
    aws_eks_node_group.main,
    aws_eks_addon.pod_identity_agent,
    aws_eks_addon.vpc_cni,
    aws_eks_addon.coredns,
    aws_eks_addon.kube_proxy,
    helm_release.metrics_server,
    helm_release.traefik,
    helm_release.cluster_autoscaler,
    helm_release.external_dns,
    helm_release.argocd,
    helm_release.prometheus_stack,
    helm_release.file-beat,
  ]

  provisioner "local-exec" {
    when    = destroy
    command = <<-EOC
      echo "Waiting for EKS cluster ${self.triggers.cluster_name} to fully delete..."
      aws eks wait cluster-deleted --name ${self.triggers.cluster_name} --region ${self.triggers.region} 2>/dev/null || true
      echo "Waiting for ENIs and security groups to release..."
      sleep 60
    EOC
  }
}

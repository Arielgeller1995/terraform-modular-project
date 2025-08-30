output "cluster_endpoint" {
  description = "EKS cluster endpoint"
  value       = aws_eks_cluster.this.endpoint
}

output "kubeconfig" {
  description = "Kubeconfig for the EKS cluster"
  value       = aws_eks_cluster.this.kubeconfig[0]
}


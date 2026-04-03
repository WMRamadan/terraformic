output "cluster_name" {
  value = aws_eks_cluster.this.name
}

output "cluster_endpoint" {
  value = aws_eks_cluster.this.endpoint
}

output "cluster_ca" {
  value = aws_eks_cluster.this.certificate_authority[0].data
}

output "node_group_names" {
  value = [for ng in aws_eks_node_group.this : ng.node_group_name]
}

output "efs_id" {
  value = var.enable_efs ? aws_efs_file_system.this[0].id : null
}

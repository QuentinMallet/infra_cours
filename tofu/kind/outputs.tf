output "kubeconfig_path" {
  description = "Path to the kubeconfig file for the local kind cluster."
  value       = kind_cluster.main.kubeconfig_path
}

output "cluster_endpoint" {
  description = "Kubernetes API endpoint of the local kind cluster."
  value       = kind_cluster.main.endpoint
}

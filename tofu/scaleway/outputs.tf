output "cluster_id" {
  description = "ID of the Scaleway Kubernetes cluster."
  value       = scaleway_k8s_cluster.main.id
}

output "kubeconfig" {
  description = "Raw kubeconfig file for the cluster."
  value       = scaleway_k8s_cluster.main.kubeconfig[0].config_file
  sensitive   = true
}

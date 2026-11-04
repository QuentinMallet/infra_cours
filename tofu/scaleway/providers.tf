provider "scaleway" {
  region = var.region
  zone   = var.zone
}

# Credentials (SCW_ACCESS_KEY / SCW_SECRET_KEY / SCW_DEFAULT_PROJECT_ID) and
# the s3 backend's AWS_ACCESS_KEY_ID / AWS_SECRET_ACCESS_KEY are read from the
# environment; see docs/runbook.md.

provider "helm" {
  kubernetes = {
    host                   = scaleway_k8s_cluster.main.kubeconfig[0].host
    token                  = scaleway_k8s_cluster.main.kubeconfig[0].token
    cluster_ca_certificate = base64decode(scaleway_k8s_cluster.main.kubeconfig[0].cluster_ca_certificate)
  }
}

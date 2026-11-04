data "scaleway_k8s_version" "latest" {
  count = var.k8s_version == null ? 1 : 0
  name  = "latest"
}

locals {
  k8s_version = coalesce(var.k8s_version, try(data.scaleway_k8s_version.latest[0].name, null))
}

resource "scaleway_vpc_private_network" "main" {
  name   = "${var.cluster_name}-pn"
  region = var.region
}

resource "scaleway_k8s_cluster" "main" {
  name                        = var.cluster_name
  region                      = var.region
  type                        = "kapsule"
  version                     = local.k8s_version
  cni                         = "cilium"
  delete_additional_resources = true
  private_network_id          = scaleway_vpc_private_network.main.id
}

# The node pool scales to 0 between classes: Kapsule's mutualized control
# plane is free, and a pool with size = 0 is allowed (min_size then defaults
# to 0, see variable node_count). The *first* apply needs node_count >= 1,
# because the argocd module's helm_release resources are created with
# wait = true and need somewhere to schedule pods. Later applies that only
# flip node_count to 0 (`just down`) leave the already-installed helm
# releases untouched; they don't get re-applied just because the pool shrank.
resource "scaleway_k8s_pool" "main" {
  cluster_id  = scaleway_k8s_cluster.main.id
  region      = var.region
  zone        = var.zone
  name        = "${var.cluster_name}-pool"
  node_type   = var.node_type
  size        = var.node_count
  min_size    = 0
  max_size    = max(var.node_count, 1)
  autoscaling = false
  autohealing = true

  lifecycle {
    create_before_destroy = true
  }
}

module "argocd" {
  source = "../modules/argocd"

  repo_url                  = var.repo_url
  target_revision           = var.target_revision
  argocd_chart_version      = var.argocd_chart_version
  argocd_apps_chart_version = var.argocd_apps_chart_version

  depends_on = [scaleway_k8s_pool.main]
}

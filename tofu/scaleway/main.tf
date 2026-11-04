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

  # "latest" moves when Scaleway ships a new release; without this a routine
  # `just up` mid-semester would trigger a control-plane upgrade. To upgrade
  # on purpose, do it from the Scaleway console/CLI between classes.
  lifecycle {
    ignore_changes = [version]
  }
}

# Between classes the pool is deleted, not resized: the Kapsule API rejects a
# pool size of 0 ("A kapsule cluster can't have less than 1 nodes") but does
# allow deleting a cluster's only pool. The control plane (free when
# mutualized) keeps etcd, so Argo CD and every synced object survive and are
# rescheduled when `just up` recreates the pool.
#
# The *first* apply needs node_count >= 1: the argocd module's helm releases
# use wait = true and need a node to schedule on. Later applies that only
# change node_count do not touch the helm releases.
resource "scaleway_k8s_pool" "main" {
  count = var.node_count > 0 ? 1 : 0

  cluster_id  = scaleway_k8s_cluster.main.id
  region      = var.region
  zone        = var.zone
  name        = "${var.cluster_name}-pool"
  node_type   = var.node_type
  size        = var.node_count
  min_size    = var.node_count
  max_size    = var.node_count
  autoscaling = false
  autohealing = true
  # No create_before_destroy: with a fixed name the replacement pool would
  # collide with the old one (the API rejects duplicate pool names).
}

module "argocd" {
  source = "../modules/argocd"

  repo_url                  = var.repo_url
  target_revision           = var.target_revision
  argocd_chart_version      = var.argocd_chart_version
  argocd_apps_chart_version = var.argocd_apps_chart_version

  depends_on = [scaleway_k8s_pool.main]
}

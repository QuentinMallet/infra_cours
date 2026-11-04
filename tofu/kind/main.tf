# Local stand-in for tofu/scaleway: the same argocd module, pointed at the
# same public repo, so a teacher can validate a class's gitops changes with
# `just kind-up` before touching real Scaleway resources.

resource "kind_cluster" "main" {
  name            = var.cluster_name
  wait_for_ready  = true
  kubeconfig_path = "${path.module}/kubeconfig"
}

module "argocd" {
  source = "../modules/argocd"

  repo_url                  = var.repo_url
  target_revision           = var.target_revision
  argocd_chart_version      = var.argocd_chart_version
  argocd_apps_chart_version = var.argocd_apps_chart_version

  depends_on = [kind_cluster.main]
}

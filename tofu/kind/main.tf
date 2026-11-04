# Local stand-in for tofu/scaleway: the same argocd module, pointed at the
# same public repo, so a teacher can validate a class's gitops changes with
# `just kind-up` before touching real Scaleway resources.
#
# The cluster itself is created by the kind CLI (see `just kind-up`), not by
# the tehcyx/kind provider: its bundled kind (provider 0.13.0) always
# bind-mounts /lib/modules, which does not exist on NixOS, so docker refuses
# to start the node. Revisit once a tehcyx/kind release skips missing
# /lib/modules like the kind CLI (>= v0.2x) does.

module "argocd" {
  source = "../modules/argocd"

  repo_url                  = var.repo_url
  target_revision           = var.target_revision
  argocd_chart_version      = var.argocd_chart_version
  argocd_apps_chart_version = var.argocd_apps_chart_version
}

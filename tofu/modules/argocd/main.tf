# Installs Argo CD (server exposed as ClusterIP only, reached via
# `kubectl port-forward` or `just ui`; no LoadBalancer, no ingress) and a
# single root Application (app-of-apps) that points Argo CD back at
# var.apps_path in var.repo_url. Everything else the class deploys is a
# plain Argo CD Application manifest committed under that path.

resource "helm_release" "argocd" {
  name             = "argocd"
  namespace        = "argocd"
  create_namespace = true

  repository = "https://argoproj.github.io/argo-helm"
  chart      = "argo-cd"
  version    = var.argocd_chart_version

  wait = true

  values = [
    yamlencode({
      server = {
        service = {
          type = "ClusterIP"
        }
      }
      configs = {
        params = {
          "server.insecure" = true
        }
      }
      dex = {
        enabled = false
      }
    })
  ]
}

resource "helm_release" "root" {
  name      = "root"
  namespace = "argocd"

  repository = "https://argoproj.github.io/argo-helm"
  chart      = "argocd-apps"
  version    = var.argocd_apps_chart_version

  wait = true

  values = [
    yamlencode({
      applications = {
        root = {
          namespace = "argocd"
          project   = "default"
          source = {
            repoURL        = var.repo_url
            targetRevision = var.target_revision
            path           = var.apps_path
          }
          destination = {
            server    = "https://kubernetes.default.svc"
            namespace = "argocd"
          }
          syncPolicy = {
            automated = {
              prune    = true
              selfHeal = true
            }
          }
        }
      }
    })
  ]

  depends_on = [helm_release.argocd]
}

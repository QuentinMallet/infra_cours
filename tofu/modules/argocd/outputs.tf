output "namespace" {
  description = "Namespace Argo CD is installed into."
  value       = helm_release.argocd.namespace
}

output "argocd_release_name" {
  description = "Name of the argo-cd helm_release."
  value       = helm_release.argocd.name
}

output "root_application_name" {
  description = "Name of the root Argo CD Application (app-of-apps) created by the argocd-apps release."
  value       = "root"
}

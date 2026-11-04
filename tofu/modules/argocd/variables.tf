variable "repo_url" {
  description = "Git repository URL that Argo CD syncs Applications from."
  type        = string
}

variable "target_revision" {
  description = "Git revision (branch, tag, or commit) that Argo CD tracks."
  type        = string
  default     = "master"
}

variable "apps_path" {
  description = "Path within repo_url containing the Argo CD Application manifests for the root app-of-apps."
  type        = string
  default     = "gitops/apps"
}

variable "argocd_chart_version" {
  description = "Exact version of the argo-cd Helm chart to install."
  type        = string
}

variable "argocd_apps_chart_version" {
  description = "Exact version of the argocd-apps Helm chart to install."
  type        = string
}

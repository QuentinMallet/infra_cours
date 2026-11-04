variable "cluster_name" {
  description = "Name of the local kind cluster."
  type        = string
  default     = "class-local"
}

variable "kubeconfig_path" {
  description = "Kubeconfig written by `kind create cluster --kubeconfig` (see `just kind-up`)."
  type        = string
  default     = "kubeconfig"
}

variable "repo_url" {
  description = "Git repository URL that Argo CD syncs Applications from. Push your changes before `just kind-up` — Argo CD pulls from this remote, not the local worktree."
  type        = string
  default     = "https://github.com/QuentinMallet/infra_cours.git"
}

variable "target_revision" {
  description = "Git revision (branch, tag, or commit) that Argo CD tracks."
  type        = string
  default     = "master"
}

variable "argocd_chart_version" {
  description = "Exact version of the argo-cd Helm chart to install."
  type        = string
  default     = "10.12.0"
}

variable "argocd_apps_chart_version" {
  description = "Exact version of the argocd-apps Helm chart to install."
  type        = string
  default     = "2.0.7"
}

variable "cluster_name" {
  description = "Name of the Scaleway Kapsule cluster."
  type        = string
}

variable "region" {
  description = "Scaleway region."
  type        = string
  default     = "fr-par"
}

variable "zone" {
  description = "Scaleway zone."
  type        = string
  default     = "fr-par-1"
}

variable "node_type" {
  description = "Scaleway instance commercial type used by the node pool."
  type        = string
  default     = "DEV1-M"
}

variable "node_count" {
  description = "Number of nodes in the pool. 0 deletes the pool between classes (the cluster and Argo CD state are kept)."
  type        = number
  default     = 1

  validation {
    condition     = var.node_count >= 0
    error_message = "node_count must be >= 0."
  }
}

variable "k8s_version" {
  description = "Kubernetes version for the cluster. Leave null to resolve the latest version Scaleway offers."
  type        = string
  default     = null
}

variable "repo_url" {
  description = "Git repository URL that Argo CD syncs Applications from."
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

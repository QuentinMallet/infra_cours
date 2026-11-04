terraform {
  required_version = ">= 1.6.0"

  required_providers {
    kind = {
      source  = "tehcyx/kind"
      version = "0.13.0"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "3.3.0"
    }
  }

  # Local backend (default): state stays on disk under this directory.
}

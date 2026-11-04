terraform {
  required_version = ">= 1.6.0"

  required_providers {
    scaleway = {
      source  = "scaleway/scaleway"
      version = "2.89.0"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "3.3.0"
    }
  }

  # Scaleway Object Storage, S3-compatible. Fill in with
  # `tofu init -backend-config=backend.hcl` (copy backend.hcl.example first).
  backend "s3" {}
}

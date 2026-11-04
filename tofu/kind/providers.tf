provider "kind" {}

provider "helm" {
  kubernetes = {
    host                   = kind_cluster.main.endpoint
    client_certificate     = kind_cluster.main.client_certificate
    client_key             = kind_cluster.main.client_key
    cluster_ca_certificate = kind_cluster.main.cluster_ca_certificate
  }
}

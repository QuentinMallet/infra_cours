# Variables reference

## `tofu/scaleway` (`variables.tf`)

| Variable | Default | Description |
|----------|---------|--------------|
| `cluster_name` | *(required)* | Name of the Scaleway Kapsule cluster |
| `region` | `fr-par` | Scaleway region |
| `zone` | `fr-par-1` | Scaleway zone |
| `node_type` | `DEV1-M` | Instance commercial type used by the node pool |
| `node_count` | `1` | Number of nodes in the pool (`>= 0`); `0` deletes the pool (Kapsule rejects a pool `size` of `0`) — recreated on the next apply with `node_count > 0`. Change it only via `just up`/`just down`, never a plain `tofu apply` while scaled down — see [Troubleshooting](troubleshooting.md#tofu-apply-fails-with-cannot-re-use-a-name-that-is-still-in-use) |
| `k8s_version` | `null` | Kubernetes version; `null` resolves to the latest version Scaleway offers |
| `repo_url` | `https://github.com/QuentinMallet/infra_cours.git` | Git repository Argo CD syncs Applications from — rewritten by `just retarget` |
| `target_revision` | `master` | Git revision Argo CD tracks |
| `argocd_chart_version` | `10.12.0` | Exact `argo-cd` Helm chart version |
| `argocd_apps_chart_version` | `2.0.7` | Exact `argocd-apps` Helm chart version |

## `tofu/kind` (`variables.tf`)

| Variable | Default | Description |
|----------|---------|--------------|
| `cluster_name` | `class-local` | Name of the local kind cluster |
| `kubeconfig_path` | `kubeconfig` | Kubeconfig path written by `kind create cluster --kubeconfig` |
| `repo_url` | `https://github.com/QuentinMallet/infra_cours.git` | Same as above — rewritten by `just retarget`; push before `just kind-up`, Argo CD pulls from this remote, not the local worktree |
| `target_revision` | `master` | Git revision Argo CD tracks |
| `argocd_chart_version` | `10.12.0` | Exact `argo-cd` Helm chart version |
| `argocd_apps_chart_version` | `2.0.7` | Exact `argocd-apps` Helm chart version |

## `tofu/modules/argocd` (`variables.tf`)

| Variable | Default | Description |
|----------|---------|--------------|
| `repo_url` | *(required)* | Git repository Argo CD syncs Applications from |
| `target_revision` | `master` | Git revision Argo CD tracks |
| `apps_path` | `gitops/apps` | Path within `repo_url` containing the root app-of-apps' Application manifests |
| `argocd_chart_version` | *(required)* | Exact `argo-cd` Helm chart version |
| `argocd_apps_chart_version` | *(required)* | Exact `argocd-apps` Helm chart version |

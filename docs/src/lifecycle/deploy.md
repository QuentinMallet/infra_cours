# Deploying

With `backend.hcl` and `terraform.tfvars` in place (see [Scaleway
setup](../getting-started/scaleway-setup.md)):

```sh
just init                 # once: tofu init with the S3 backend
just up 1                 # first apply — needs node_count >= 1, see below
```

## Why the first apply needs at least one node

`tofu/scaleway/main.tf` installs Argo CD and its root Application
(`helm_release.argocd`, `helm_release.root`) with `wait = true`. Helm waits
for those releases' pods to actually become ready, and Kapsule won't even
create a pool with `node_count = 0` (it rejects a pool `size` of `0`) — so
the very first apply always needs a real pool. `just up 1` (the default)
applies with `node_count = 1` for this reason.

Once Argo CD is installed, `just down` runs a single apply targeted at
`scaleway_k8s_pool.main`, which deletes the pool without touching the helm
releases. Bringing the pool back is trickier: with no pool the Kubernetes
API is unreachable, so the `helm` provider can't see the existing releases
and a full apply would try to reinstall them. `just up`/`just scale`
avoid that by applying the pool first (targeted), then running a full
apply once the API is back — see [Scaling between classes](scaling.md).

## Get the kubeconfig

```sh
just kubeconfig
export KUBECONFIG=$(pwd)/kubeconfig
```

`just kubeconfig` reads the `kubeconfig` OpenTofu output
(`tofu/scaleway/outputs.tf`) and writes it to `./kubeconfig` with `chmod
600`. That file is gitignored.

## Open the Argo CD UI

```sh
just ui                   # port-forwards argocd-server to http://localhost:8080
just password              # prints the initial admin password
```

Log in as `admin` with that password. Argo CD's server is installed as a
plain `ClusterIP` Service (`tofu/modules/argocd/main.tf`), so a
port-forward is the only way to reach it — there is no LoadBalancer or
Ingress, deliberately: see [Cost notes](../reference/costs.md).

From the UI (or just by watching `kubectl get applications -n argocd`) you
should see the root `Application` and, once it has synced, the `demo`
Application underneath it.

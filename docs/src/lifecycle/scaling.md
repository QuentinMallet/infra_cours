# Scaling between classes

Delete the node pool when a class ends and recreate it before the next one.

```sh
just down                 # deletes the pool
just up 2                 # or: just scale 2 — recreates it with any node_count
```

`just up n` and `just scale n` both end up running `tofu apply -var
node_count={{n}}` (see the [justfile reference](../reference/justfile.md)
for the exact two-apply sequence); `up` just defaults `n` to `1`. `just
down` is a single targeted apply with `node_count=0`.

## Why the pool is deleted, not resized to 0

Scaleway's Kapsule API rejects a pool `size` of `0` ("A kapsule cluster
can't have less than 1 nodes"). `scaleway_k8s_pool.main`
(`tofu/scaleway/main.tf`) is conditional on that: `count = var.node_count
> 0 ? 1 : 0`, with `min_size`/`max_size` both set to `node_count`. `just
down` applies `node_count = 0` targeted at that resource, which deletes
the pool instead of resizing it.

## What happens with no pool

- the cluster's status becomes `pool_required` and the API server is
  unreachable — `kubectl`, `just ui`, and `just password` all fail (the
  API server's DNS name stops resolving, so requests time out). See
  [Troubleshooting](../reference/troubleshooting.md).
- the Kapsule control plane keeps running (Scaleway's mutualized control
  plane has no separate cost) and etcd is untouched: the `argocd`
  namespace, every Helm release secret, and every Argo CD `Application`
  all survive.
- the targeted `just down` apply only touches `scaleway_k8s_pool.main` —
  the already-installed `helm_release.argocd` / `helm_release.root`
  resources aren't re-evaluated.

Measured end-to-end on Scaleway (2026-11-04): `just down` took about 1.5
minutes; `just up 1` took about 5 minutes (pool creation alone is 3-5
minutes). The kubeconfig stays valid throughout — it points at the
cluster, not the pool.

## Why `just up`/`just scale` apply twice

With no pool, the Kubernetes API server is unreachable, so OpenTofu's
`helm` provider can't query it and reports `helm_release.argocd` /
`helm_release.root` as deleted. A single full apply at that point would
try to reinstall them. `just up`/`just scale` avoid that by applying
`-target=scaleway_k8s_pool.main` first — recreating the pool and bringing
the API server back — then running a full apply once the provider can see
the real state. Each `apply` prompts for confirmation unless
`TF_CLI_ARGS_apply=-auto-approve` is set.

## What happens when the pool comes back

Argo CD's pods, and every workload's pods, get scheduled onto the new
node. Pods that belonged to the deleted node can briefly show as
`Terminating` — see [Troubleshooting](../reference/troubleshooting.md).
Nothing needs to be re-applied by hand for Argo CD itself: once its own
pods are ready it resumes reconciling every tracked `Application` —
including anything that changed in `gitops/apps/` or `gitops/workloads/*`
while the pool was deleted, thanks to `syncPolicy.automated` (prune +
selfHeal). There is no manual re-sync step.

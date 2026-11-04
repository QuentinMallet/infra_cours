# Scaling between classes

Scale the node pool down when a class ends and back up before the next one.

```sh
just down                 # node_count -> 0
just up 2                 # or: just scale 2 — any node_count
```

`just up n` and `just scale n` both run the same `tofu apply -var
node_count={{n}}`; `up` just defaults `n` to `1` (see the [justfile
reference](../reference/justfile.md)).

## What happens at 0 nodes

`scaleway_k8s_pool.main` (`tofu/scaleway/main.tf`) allows `size = 0`
(`min_size = 0` is set explicitly, since the provider would otherwise
default `min_size` to 1 whenever `size > 0`). Scaling to 0:

- deletes every Instance in the pool — that's where the cost saving comes
  from (see [Cost notes](../reference/costs.md));
- leaves the Kapsule control plane running (Scaleway's mutualized control
  plane has no separate cost regardless of pool size);
- does **not** touch the already-installed `helm_release.argocd` /
  `helm_release.root` resources — OpenTofu only re-applies a resource when
  its own config changes, and scaling the pool doesn't change the helm
  release config, so Argo CD's install step isn't repeated.

## What happens when nodes come back

Nothing needs to be re-applied by hand for Argo CD itself: its Deployments
scale back up as soon as the pool has nodes to schedule them on, and once
Argo CD's own pods are ready it resumes reconciling every tracked
`Application` — including anything that changed in `gitops/apps/` or
`gitops/workloads/*` while the pool was at 0, thanks to `syncPolicy.automated`
(prune + selfHeal). There is no manual re-sync step.

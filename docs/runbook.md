# Runbook

## Prerequisites

```sh
nix develop
```

gives you `opentofu`, `kubectl`, `helm`, `argocd`, `kind`, `scaleway-cli`,
`k9s`, `kustomize`, `kubeconform`, `just`, `jq`, `yq`. `.envrc` runs
`use flake`, so `direnv allow` does the same automatically.

## One-time setup (per Scaleway project)

Create an API key and an Object Storage bucket for the OpenTofu state:

```sh
scw init                                         # or export SCW_ACCESS_KEY/SCW_SECRET_KEY/SCW_DEFAULT_PROJECT_ID
scw object bucket create name=my-class-tfstate region=fr-par
```

Export credentials for both the Scaleway provider and the S3-compatible
backend (same key pair, two env var names):

```sh
export SCW_ACCESS_KEY=...
export SCW_SECRET_KEY=...
export SCW_DEFAULT_PROJECT_ID=...
export AWS_ACCESS_KEY_ID=$SCW_ACCESS_KEY
export AWS_SECRET_ACCESS_KEY=$SCW_SECRET_KEY
```

Copy the example files and fill them in:

```sh
cp tofu/scaleway/backend.hcl.example tofu/scaleway/backend.hcl        # set bucket
cp tofu/scaleway/terraform.tfvars.example tofu/scaleway/terraform.tfvars
```

Point Argo CD at *your* clone (it must be public). This rewrites the repo URL
in `gitops/apps/*.yaml`, the tofu defaults and the tfvars example; it defaults
to the `origin` remote:

```sh
just retarget                                  # or: just retarget https://github.com/me/my-class.git
cp tofu/scaleway/terraform.tfvars.example tofu/scaleway/terraform.tfvars   # re-copy after retarget
git commit -am "chore: retarget class repo" && git push
```

Argo CD tracks `target_revision` (default `master`).

## Day-to-day

```sh
just init                 # once, after backend.hcl is filled in
just up 1                 # first apply: needs node_count >= 1 (see tofu/scaleway/main.tf)
just kubeconfig
export KUBECONFIG=$(pwd)/kubeconfig
just ui                   # port-forward argocd-server to localhost:8080
just password             # initial admin password
```

Between classes:

```sh
just down                 # node_count -> 0; control plane stays, nothing left to bill
```

Before the next class:

```sh
just up 2                 # or any node_count
```

At the end of the module:

```sh
just destroy              # cluster, pool, private network gone
```

The state bucket is not deleted; remove it by hand with
`scw object bucket delete name=... --force` if you no longer need it.

## Local testing with kind

```sh
# push your gitops changes first — Argo CD pulls from origin, not your
# local worktree
git push

just kind-up               # local kind cluster, same argocd module as Scaleway
just kubeconfig            # not needed for kind: KUBECONFIG is tofu/kind/kubeconfig
export KUBECONFIG=$(pwd)/tofu/kind/kubeconfig
just kind-down
```

## Changing the class's workload

Edit `gitops/workloads/<app>/kustomization.yaml` (the `images:` block is
where the image/tag lives), push to the tracked revision. Argo CD's
`syncPolicy.automated` (prune + selfHeal) applies it on its own — no manual
`kubectl apply`. See `gitops/README.md` to add a brand new workload.

## Cost notes

- A pool scaled to `node_count = 0` has no Instance cost; Kapsule's
  mutualized control plane is free regardless of pool size.
- LoadBalancer Services and block-storage PVCs keep billing even while the
  node pool is at 0 — that's why this template only uses ClusterIP Services
  and no PersistentVolumeClaims. Keep any new workload the same way.
- `just destroy` removes the cluster, pool, and private network
  (`delete_additional_resources = true`), but not the Object Storage state
  bucket.

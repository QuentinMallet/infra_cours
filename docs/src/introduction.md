# Introduction

This repository is a reusable template for running a Kubernetes class: one
OpenTofu apply stands up a Scaleway Kapsule cluster and installs Argo CD
into it; Argo CD then takes over and syncs the actual class workloads from
this same repository via GitOps. Between classes the node pool scales to 0
(no instance cost); before a class it scales back up. At the end of the
module the whole cluster is destroyed.

## Architecture

```text
 OpenTofu (tofu/scaleway)
   |
   |-- creates --> Scaleway Kapsule cluster + node pool
   |-- installs -> Argo CD (helm_release.argocd)
   `-- installs -> root Application "root" (helm_release.root, argocd-apps chart)
                     |
                     | watches gitops/apps/ (app-of-apps)
                     v
            Argo CD Application: demo
                     |
                     | watches gitops/workloads/demo/
                     v
              Deployment + Service (ClusterIP)
```

`tofu/scaleway` and `tofu/kind` are two root modules that both call the same
`tofu/modules/argocd` module, so a local `kind` cluster exercises exactly
the same Argo CD install path as the real Scaleway cluster — see
[Local testing with kind](local-testing.md).

Once the root Application exists, every file under `gitops/apps/` is a
plain Argo CD `Application` manifest, and every Application's `syncPolicy`
is `automated` (prune + selfHeal): editing files in this repo and pushing
is the only operation needed to change what is running in the cluster — no
`kubectl apply`, no `argocd app sync`. See [Managing
workloads](workloads.md).

## Layout

```text
flake.nix               # nix develop shell: tofu, kubectl, helm, argocd, kind, ...
justfile                 # init / up / scale / down / destroy / kubeconfig / ui / lint

tofu/
  modules/argocd/         # installs argo-cd + a root Application (app-of-apps)
  scaleway/               # root module: Kapsule cluster + argocd module (S3 backend)
  kind/                   # root module: the SAME argocd module on a kind CLI cluster

gitops/
  apps/                   # one Argo CD Application manifest per class workload
  workloads/demo/         # kustomize-able manifests for the demo workload

docs/                     # this book (nix build .#doc / mdbook serve docs)
```

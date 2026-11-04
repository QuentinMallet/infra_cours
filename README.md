# infra_cours

Reusable template for teaching classes: OpenTofu provisions a Scaleway
Kapsule cluster and installs Argo CD into it; Argo CD then syncs the actual
class workloads from this repo via GitOps. The node pool is deleted between
classes and recreated before one; the cluster is destroyed at the end of the
module.

## Layout

```
flake.nix               # nix develop shell: tofu, kubectl, helm, argocd, kind, ...
justfile                 # init / up / scale / down / destroy / kubeconfig / ui / lint

tofu/
  modules/argocd/         # installs argo-cd + a root Application (app-of-apps)
  scaleway/               # root module: Kapsule cluster + argocd module (S3 backend)
  kind/                   # root module: the SAME argocd module on a kind CLI cluster

gitops/
  apps/                   # one Argo CD Application manifest per class workload
  workloads/demo/         # kustomize-able manifests for the demo workload

docs/                     # mdBook guide (nix build .#doc)
```

`tofu/scaleway` and `tofu/kind` both call the same `tofu/modules/argocd`
module, so a workstation `kind` cluster exercises exactly the same Argo CD
install path as the real Scaleway cluster.

## Quick start

```sh
nix develop            # or: direnv allow

cp tofu/scaleway/backend.hcl.example tofu/scaleway/backend.hcl        # fill in bucket
cp tofu/scaleway/terraform.tfvars.example tofu/scaleway/terraform.tfvars

just init
just up 1               # first apply needs >= 1 node
just kubeconfig && export KUBECONFIG=$(pwd)/kubeconfig
just ui                 # http://localhost:8080
just password

just down               # between classes
just up 2               # before the next one
just destroy            # end of the module
```

Local-only testing, no Scaleway account needed:

```sh
just kind-up
just kind-down
```

See the book for prerequisites, the one-time Scaleway setup, cost notes,
and adding a new class workload:

```sh
nix build .#doc && xdg-open result/index.html     # or: mdbook serve docs
```

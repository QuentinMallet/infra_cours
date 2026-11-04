# Local testing with kind

`tofu/kind` is a second OpenTofu root module that calls the exact same
`tofu/modules/argocd` module as `tofu/scaleway`, so you can exercise the
whole Argo CD install path — and validate a class's `gitops/` changes —
without touching Scaleway or paying for anything.

```sh
just kind-up
export KUBECONFIG=$(pwd)/tofu/kind/kubeconfig
just ui                    # same recipe as on Scaleway
just password
just kind-down              # deletes the cluster and tofu/kind's local state
```

`just kind-up` creates the cluster, runs `tofu -chdir=tofu/kind init`, then
`tofu -chdir=tofu/kind apply`. `just kind-down` deletes the kind cluster and
removes `tofu/kind`'s local state files and kubeconfig.

## Why the kind CLI and not the tehcyx/kind OpenTofu provider

`tofu/kind/main.tf` only contains the `argocd` module call — the cluster
itself is created by the `kind` CLI from the `just kind-up` recipe, not by
an OpenTofu `kind_cluster` resource. The `tehcyx/kind` provider (pinned
version 0.13.0 in earlier iterations of this template) bundles its own copy
of kind, which unconditionally bind-mounts `/lib/modules` into the control
plane container; that path does not exist on NixOS, so `docker run` fails
with exit status 126 and the node never starts. The `kind` CLI itself
(packaged in `flake.nix`) skips that mount when the path is absent, so it
works on NixOS where the provider doesn't. See [the troubleshooting
page](reference/troubleshooting.md) if this surfaces again after a provider
upgrade.

## Testing a branch before merging

Argo CD pulls from the remote repository, not your local worktree — a
branch has to be pushed before Argo CD can see it. To point a kind cluster
at an unmerged branch instead of the default `target_revision`:

```sh
tofu -chdir=tofu/kind apply -var target_revision=my-branch
```

(the branch must already be pushed to the remote configured as `repo_url`).

# Prerequisites

Enter the dev shell before running anything else:

```sh
nix develop
```

or, with [direnv](https://direnv.net/) installed, just `direnv allow` once —
`.envrc` runs `use flake` and does the same thing automatically on every
`cd` into the repository.

The shell (`flake.nix`) provides:

| Tool | Purpose |
|------|---------|
| `opentofu` | provisions the cluster and installs Argo CD |
| `kubectl` | talk to the cluster (port-forward, secrets, ...) |
| `kubernetes-helm` | used indirectly by OpenTofu's `helm` provider |
| `argocd` | optional Argo CD CLI |
| `kind` | local Kubernetes cluster for testing without Scaleway |
| `scaleway-cli` (`scw`) | create the API key, project, and state bucket |
| `k9s` | terminal UI for browsing the cluster |
| `kustomize` | render `gitops/workloads/*` manifests |
| `kubeconform` | validate manifests (used by `just lint`) |
| `just` | task runner — see the [justfile reference](../reference/justfile.md) |
| `jq`, `yq-go` | JSON/YAML scripting |

A Scaleway account with billing enabled is needed for the real cluster;
[Local testing with kind](../local-testing.md) needs none of that.

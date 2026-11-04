# justfile reference

All recipes run from the repository root; `just` itself is provided by the
`nix develop` shell.

| Recipe | Runs | Notes |
|--------|------|-------|
| `just` (default) | `just --list` | lists all recipes |
| `just init` | `tofu -chdir=tofu/scaleway init -backend-config=backend.hcl` | one-time, after `backend.hcl` is filled in |
| `just up n="1"` | two applies: `apply -target=scaleway_k8s_pool.main -var node_count={{n}}`, then `apply -var node_count={{n}}` | use before a class; pool first (the helm provider can't reach the API without it), then a full apply reconciles Argo CD |
| `just scale n` | same two applies as `just up n` | explicit node count, no default |
| `just down` | one targeted apply: `apply -target=scaleway_k8s_pool.main -var node_count=0` | between classes; deletes the pool (Kapsule rejects `size = 0`) |
| `just destroy` | `tofu -chdir=tofu/scaleway destroy` | end of module; state bucket is kept |
| `just kubeconfig` | writes `./kubeconfig` from the `kubeconfig` tofu output via a mode-600 temp file + `mv` | prints the `export KUBECONFIG=...` line to run yourself |
| `just retarget url=<origin, as https>` | rewrites every occurrence of the old `repoURL` across `gitops/apps/*.yaml`, `tofu/**/*.tf`, `tofu/**/*.example`, `tofu/**/*.tfvars` to `url` | see below |
| `just ui` | `kubectl -n argocd port-forward svc/argocd-server 8080:80` | Argo CD UI at `http://localhost:8080` |
| `just password` | reads and base64-decodes the `argocd-initial-admin-secret` Secret | initial `admin` password |
| `just kind-up name="class-local"` | `kind create cluster` (if absent) or `kind export kubeconfig` (if it already exists) + `tofu -chdir=tofu/kind init`/`apply` | see [Local testing with kind](../local-testing.md) |
| `just kind-down name="class-local"` | `kind delete cluster` + removes `tofu/kind`'s local state/kubeconfig | |
| `just lint` | `tofu fmt -check`, `tofu validate` on every root/module, `kustomize build \| kubeconform` on every workload, `kubeconform` on `gitops/apps/*.yaml` | CI-style check, no cluster needed |

Every `tofu apply` above prompts for confirmation; set
`TF_CLI_ARGS_apply=-auto-approve` to run non-interactively.

## `retarget`

```sh
just retarget                                   # url defaults to: git remote get-url origin, rewritten git@host:path or ssh://git@host/path -> https://host/path
just retarget https://github.com/me/my-class.git
```

Finds the current `repoURL` value by reading the first `repoURL:` line out
of `gitops/apps/demo.yaml`, then greps every `*.yaml`/`*.tf`/`*.example`/
`*.tfvars` file under `gitops/` and `tofu/` for that exact string and
replaces it with the new URL — including a gitignored local
`terraform.tfvars`, if one exists. It only edits files, it does not commit
or push — do that yourself afterward. See [Starting a new
class](../getting-started/new-class.md).

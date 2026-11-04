# Managing workloads

Argo CD's root Application (installed by `tofu/modules/argocd`) watches
`gitops/apps/` in this repository on the tracked `target_revision` (default
`master`). Every file in that directory is a plain Argo CD `Application`
manifest, and every one of those has `syncPolicy.automated` (prune +
selfHeal): the cluster is kept matching whatever is committed under
`gitops/apps/` and `gitops/workloads/*` — no manual `kubectl apply` or
`argocd app sync` needed, ever.

## Changing the demo workload's image

`gitops/workloads/demo/kustomization.yaml` has an `images:` block:

```yaml
images:
  - name: nginxinc/nginx-unprivileged
    newTag: "1.27"
```

Bump `newTag` (or point `name`/`newTag` at a different image entirely),
commit, and push to the tracked revision. Argo CD notices the drift between
the live Deployment and the newly-rendered manifest and applies it on its
own.

## Adding a new workload

1. Copy `gitops/workloads/demo/` to a new directory, e.g.
   `gitops/workloads/my-app/`, and edit its `deployment.yaml` /
   `service.yaml` (or add more resources — anything `kustomize build` can
   render).
2. Copy `gitops/apps/demo.yaml` to `gitops/apps/my-app.yaml`. Update:
   - `metadata.name`
   - `spec.source.path` (point it at `gitops/workloads/my-app`)
   - `spec.destination.namespace`
3. Commit and push to the tracked revision. Argo CD notices the new file
   under `gitops/apps/` and creates the Application; from there its own
   sync policy takes over.

## Keep workloads ClusterIP-only, no PVCs

A node pool scaled to 0 between classes still pays for a `LoadBalancer`
Service or a block-storage `PersistentVolumeClaim` — that's exactly what
this template is built to avoid (see [Cost notes](reference/costs.md)).
Keep every new workload `ClusterIP`-only with no PVC, the same way
`gitops/workloads/demo` does.

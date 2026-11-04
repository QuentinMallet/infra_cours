# gitops

Argo CD's root Application (installed by `tofu/modules/argocd`) watches
`gitops/apps` in this repo on the `master` branch. Every file in that
directory is a plain Argo CD `Application` manifest; `syncPolicy.automated`
(prune + selfHeal) keeps the cluster matching what's committed here — no
manual `kubectl apply` or `argocd app sync` needed once the root app exists.

## Adding a new workload

1. Copy `gitops/workloads/demo/` to a new directory, e.g.
   `gitops/workloads/my-app/`, and edit its `deployment.yaml` / `service.yaml`
   (or add more resources — anything `kustomize build` can render).
2. Copy `gitops/apps/demo.yaml` to `gitops/apps/my-app.yaml`. Update:
   - `metadata.name`
   - `spec.source.path` (point it at `gitops/workloads/my-app`)
   - `spec.destination.namespace`
3. Commit and push to `master` (or whatever `target_revision` the cluster
   was deployed with). Argo CD notices the new file under `gitops/apps` and
   creates the Application; from there its own sync policy takes over.

Keep workloads ClusterIP-only with no PVC: a scaled-to-zero cluster between
classes still pays for a LoadBalancer Service or a block volume, which is
exactly what this template is built to avoid (see `docs/runbook.md`).

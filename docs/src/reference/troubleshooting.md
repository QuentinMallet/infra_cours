# Troubleshooting

## First apply hangs, seemingly forever

The first `just up`/`tofu apply` against `tofu/scaleway` installs Argo CD
with `helm_release.argocd` / `helm_release.root`, both set `wait = true` —
Helm blocks until their pods are `Ready`. If that apply was run with
`node_count = 0`, there is nowhere for those pods to schedule and the apply
sits there until Helm's wait times out. Always run the first apply with at
least one node: `just up 1` (the default) — see [Deploying](../lifecycle/deploy.md).

## Argo CD shows "repository not found" / "repository not accessible"

This template wires no git credentials, SSH deploy key, or Argo CD
repository registration for `repo_url` — it only works against a **public**
repository. A private repo (or a repo renamed/moved without updating
`repoURL`) surfaces exactly this error in the Application's sync status.
Fix: make the repository public, or run `just retarget` again with the
correct URL. See [Starting a new class](../getting-started/new-class.md).

## `kubectl`, `just ui`, `just password` fail between classes

With the node pool deleted (`just down`, or any class break), the cluster
status is `pool_required` and the API server is unreachable: the API
server's DNS name stops resolving and `kubectl` commands time out
(`i/o timeout`). This is expected — there is no node to run anything on,
so there is nothing to reach. Run `just up n` first — see [Scaling between
classes](../lifecycle/scaling.md).

## Pods stuck `Terminating` right after `just up`

For a minute or two after the pool comes back, `kubectl get pods -A` can
still show pods that belonged to the previous (deleted) node as
`Terminating`. They clear once Kubernetes garbage-collects the old `Node`
object — no action needed, just wait.

## `-var target_revision=<branch>` doesn't change what `demo` runs

Every file under `gitops/apps/*.yaml` hardcodes `spec.source.targetRevision:
master` (see `gitops/apps/demo.yaml`). Overriding `target_revision` on
`tofu apply` only changes which revision the *root* Application tracks —
child Applications such as `demo` still sync from `master` unless their
own `targetRevision` is edited too. See [Starting a new
class](../getting-started/new-class.md).

## kind cluster fails to start on NixOS

If using the `tehcyx/kind` OpenTofu provider directly (rather than the
`kind` CLI this template's `just kind-up` uses): provider 0.13.0 bundles a
kind library that unconditionally bind-mounts `/lib/modules`, which does
not exist on NixOS — `docker run` fails with exit status 126 and the node
never starts. This template avoids the provider entirely and creates the
cluster with the `kind` CLI instead (see [Local testing with
kind](../local-testing.md)); if you hit this, check you're still going
through `just kind-up` and not a raw `tofu apply` against a `kind_cluster`
resource.

## kubectl / argocd commands hit the wrong cluster

Both `tofu/scaleway` and `tofu/kind` write their own kubeconfig
(`./kubeconfig` and `tofu/kind/kubeconfig` respectively). If `KUBECONFIG`
is left pointing at one while you're meaning to operate on the other (for
example, after switching from `just kind-up` testing back to the real
cluster), every `kubectl`/`just ui`/`just password` command silently talks
to the wrong cluster instead of failing. Check `echo $KUBECONFIG` and
re-export it from the right file after switching contexts — see
[Deploying](../lifecycle/deploy.md) and [Local testing with
kind](../local-testing.md).

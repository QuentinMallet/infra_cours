# Cost notes

- A node pool scaled to `node_count = 0` has **no Instance cost**.
  `scaleway_k8s_pool.main` allows `size = 0` (`tofu/scaleway/main.tf` sets
  `min_size = 0` explicitly — left at its default, the provider would set
  `min_size = 1` whenever `size > 0`, which would block ever reaching 0).
- Kapsule's control plane is **free and mutualized** regardless of pool
  size — scaling to 0 does not lose the cluster or the Argo CD install, and
  the control plane keeps running and billing nothing in between classes.
- `LoadBalancer` Services and block-storage `PersistentVolumeClaim`s **keep
  billing even while the node pool is at 0**. That's why:
  - Argo CD's own server is installed as `ClusterIP`
    (`tofu/modules/argocd/main.tf`), reached only via `kubectl
    port-forward` / `just ui` — never a LoadBalancer or Ingress;
  - the `demo` workload (`gitops/workloads/demo/service.yaml`) is likewise
    `ClusterIP`-only and declares no PVC.
- Keep every new class workload the same way — see [Managing
  workloads](../workloads.md#keep-workloads-clusterip-only-no-pvcs). If a
  workload truly needs external access, prefer `kubectl port-forward` for
  class demos over provisioning a real LoadBalancer.
- `just destroy` removes the cluster, pool, and private network
  (`delete_additional_resources = true`) but **not** the Object Storage
  state bucket — see [Destroying](../lifecycle/destroy.md) for how to
  remove that by hand if it's no longer needed.

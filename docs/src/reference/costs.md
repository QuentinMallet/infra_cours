# Cost notes

- `node_count = 0` has **no Instance cost** because the pool is deleted
  entirely, not resized to 0: Kapsule rejects a pool `size` of `0` ("A
  kapsule cluster can't have less than 1 nodes"), so
  `scaleway_k8s_pool.main` (`tofu/scaleway/main.tf`) only exists when
  `node_count > 0`, and `just down` removes it.
- Kapsule's control plane is **free and mutualized** regardless of pool
  size — deleting the pool does not lose the cluster or the Argo CD
  install (etcd is untouched), and the control plane keeps running and
  billing nothing in between classes.
- `LoadBalancer` Services and block-storage `PersistentVolumeClaim`s **keep
  billing even with no node pool at all**. That's why:
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

# Destroying

At the end of the module:

```sh
just destroy
```

This runs `tofu -chdir=tofu/scaleway destroy`. The node pool
(`scaleway_k8s_pool.main`) and the private network
(`scaleway_vpc_private_network.main`) are plain OpenTofu resources, removed
through the normal destroy dependency graph — not because of any special
flag. `scaleway_k8s_cluster.main` separately sets
`delete_additional_resources = true` (`tofu/scaleway/main.tf`), which cleans
up resources the *cluster* created that OpenTofu never tracked directly:
`LoadBalancer` Services and the block volumes backing any
`PersistentVolumeClaim`. This template's workloads use neither (see
[Managing workloads](../workloads.md#keep-workloads-clusterip-only-no-pvcs)),
so there's nothing left over to find and delete by hand on the Scaleway
console either way.

## What is *not* deleted

The Object Storage bucket holding the OpenTofu state
([Scaleway setup](../getting-started/scaleway-setup.md)) is never touched by
`just destroy` — OpenTofu's `s3` backend only reads/writes a state file
inside it, it never manages the bucket resource itself. If you don't plan
to reuse the bucket for another class, delete it explicitly:

```sh
scw object bucket delete name=my-class-tfstate --force
```

(replace the bucket name with whatever you created in [Scaleway
setup](../getting-started/scaleway-setup.md)).

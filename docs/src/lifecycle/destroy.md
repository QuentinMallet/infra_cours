# Destroying

At the end of the module:

```sh
just destroy
```

This runs `tofu -chdir=tofu/scaleway destroy`. Because
`scaleway_k8s_cluster.main` has `delete_additional_resources = true`
(`tofu/scaleway/main.tf`), destroying it also removes the node pool and the
`scaleway_vpc_private_network.main` private network — there's nothing left
over to find and delete by hand on the Scaleway console.

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

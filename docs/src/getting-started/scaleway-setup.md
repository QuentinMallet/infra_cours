# Scaleway setup

This is a one-time setup per Scaleway project (per class, or reused across
classes if you want to keep the state bucket).

## API key and project

```sh
scw init
```

walks through creating/selecting a Scaleway project and an API key, and
writes `~/.config/scw/config.yaml`. Alternatively, export the credentials
directly without `scw init`:

```sh
export SCW_ACCESS_KEY=...
export SCW_SECRET_KEY=...
export SCW_DEFAULT_PROJECT_ID=...
```

These three are read by the `scaleway` OpenTofu provider
(`tofu/scaleway/providers.tf`) straight from the environment — there is no
provider block with hardcoded credentials.

## State bucket (Object Storage)

OpenTofu state lives in an S3-compatible Scaleway Object Storage bucket, not
on disk:

```sh
scw object bucket create name=my-class-tfstate region=fr-par
```

The `s3` backend (`tofu/scaleway/versions.tf`) additionally wants AWS-style
env var names, set to the *same* Scaleway key pair:

```sh
export AWS_ACCESS_KEY_ID=$SCW_ACCESS_KEY
export AWS_SECRET_ACCESS_KEY=$SCW_SECRET_KEY
```

## backend.hcl and terraform.tfvars

Both are gitignored (per-deployment, never committed) and have `.example`
counterparts to copy:

```sh
cp tofu/scaleway/backend.hcl.example tofu/scaleway/backend.hcl
cp tofu/scaleway/terraform.tfvars.example tofu/scaleway/terraform.tfvars
```

Edit `backend.hcl` and set `bucket` to the name you created above. Edit
`terraform.tfvars` if you want a different `cluster_name` or starting
`node_count` than the example defaults.

With both files in place, continue to [Starting a new
class](new-class.md) or straight to [Deploying](../lifecycle/deploy.md) if
you're reusing an existing clone.

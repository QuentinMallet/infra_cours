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
on disk. The `s3` backend (`tofu/scaleway/versions.tf`) talks to it with
AWS-style env var names, set to the *same* Scaleway key pair:

```sh
export AWS_ACCESS_KEY_ID=$SCW_ACCESS_KEY
export AWS_SECRET_ACCESS_KEY=$SCW_SECRET_KEY
```

**Project gotcha:** the S3 API ignores `SCW_DEFAULT_PROJECT_ID` — a bucket
always lands in the API key's *preferred project*, and `scw object bucket
create` has no `--project-id` flag to steer it elsewhere. To put the state
bucket in a specific project instead, append the project ID to the access
key, for both the bucket creation and the `s3` backend above:
`AWS_ACCESS_KEY_ID="$SCW_ACCESS_KEY@<project-id>"`. That `@<project-id>`
suffix only works through an AWS-compatible client, so create the bucket
with the `aws` CLI rather than `scw object bucket create`:

```sh
nix shell nixpkgs#awscli2        # awscli2 isn't in this flake's devShell

export AWS_ACCESS_KEY_ID="$SCW_ACCESS_KEY@<project-id>"
export AWS_SECRET_ACCESS_KEY=$SCW_SECRET_KEY

aws --endpoint-url https://s3.fr-par.scw.cloud --region fr-par \
  s3 mb s3://my-class-tfstate
aws --endpoint-url https://s3.fr-par.scw.cloud --region fr-par \
  s3api put-bucket-versioning --bucket my-class-tfstate \
  --versioning-configuration Status=Enabled
```

The alternative is setting the API key's preferred project in the
Scaleway console — then plain `scw object bucket create
name=my-class-tfstate region=fr-par` lands in that project, and the
non-suffixed `AWS_ACCESS_KEY_ID` above is enough for the backend too.

Recommended either way: a dedicated Scaleway project per class, so the
state bucket and the cluster it describes live in the same place —

```sh
scw account project create name=my-class
export SCW_DEFAULT_PROJECT_ID=...                # the project ID just printed
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

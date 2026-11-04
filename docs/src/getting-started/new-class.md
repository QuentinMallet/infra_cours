# Starting a new class

Each class should work from its own clone of this template, pointed at its
own repository, because Argo CD's root Application and every workload
Application read `repoURL` out of `gitops/apps/*.yaml` — they must resolve
to a repo Argo CD can actually pull from.

## 1. Clone the template

Clone (or use "Use this template" on a repo host that supports it) into a
new repository under your own account/org.

## 2. The repository must be public

Argo CD's `source.repoURL` in `gitops/apps/*.yaml` and the `repo_url`
OpenTofu variables point at a plain `https://` git URL with no credentials
configured anywhere in this template — there is no git credentials secret,
SSH deploy key, or Argo CD repository registration wired up. The cluster
can only sync from a **public** repository as shipped.

## 3. Point everything at your clone

```sh
just retarget                                  # defaults to the origin remote, rewritten to https
# or, for a different URL:
just retarget https://github.com/me/my-class.git
```

This rewrites the old `repoURL` everywhere it appears: `gitops/apps/*.yaml`,
the `repo_url` default in both `tofu/scaleway/variables.tf` and
`tofu/kind/variables.tf`, `tofu/scaleway/terraform.tfvars.example`, and —
if present — your own gitignored `tofu/scaleway/terraform.tfvars`. See the
[justfile reference](../reference/justfile.md#retarget) for exactly what it
touches.

## 4. Commit and publish the change

```sh
git commit -am "chore: retarget class repo"
```

Then publish that commit to the remote so Argo CD can see it. Argo CD only
ever reads from the remote — not from your local worktree — so nothing is
"live" until the commit has been published. From here, continue to
[Scaleway setup](scaleway-setup.md) if not done yet, then
[Deploying](../lifecycle/deploy.md).

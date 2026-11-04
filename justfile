set dotenv-load := false

default:
    @just --list

# One-time: tofu init with the Scaleway Object Storage backend.
init:
    tofu -chdir=tofu/scaleway init -backend-config=backend.hcl

# Apply with n nodes (default 1). Use before a class.
up n="1":
    tofu -chdir=tofu/scaleway apply -var node_count={{ n }}

# Apply with an explicit node count.
scale n:
    tofu -chdir=tofu/scaleway apply -var node_count={{ n }}

# Scale the pool to 0 between classes. Control plane stays, nothing to pay for.
down:
    tofu -chdir=tofu/scaleway apply -var node_count=0

# Tear everything down at the end of the module. The state bucket is kept.
destroy:
    tofu -chdir=tofu/scaleway destroy

# Write ./kubeconfig from the tofu output.
kubeconfig:
    tofu -chdir=tofu/scaleway output -raw kubeconfig > kubeconfig
    chmod 600 kubeconfig
    echo "export KUBECONFIG=$(pwd)/kubeconfig"

# Point every Argo CD source at this clone's repo (default: the origin remote, as https).
retarget url=`git remote get-url origin | sed -E 's#^git@([^:]+):#https://\1/#'`:
    #!/usr/bin/env sh
    set -eu
    old=$(sed -n 's/^ *repoURL: *//p' gitops/apps/demo.yaml | head -n1)
    grep -rlF "$old" gitops tofu --include='*.yaml' --include='*.tf' --include='*.example' | xargs sed -i "s#$old#{{ url }}#g"
    echo "repo URL: $old -> {{ url }} (commit and push before applying)"

# Port-forward the Argo CD UI to http://localhost:8080.
ui:
    kubectl -n argocd port-forward svc/argocd-server 8080:80

# Print the Argo CD initial admin password.
password:
    kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath='{.data.password}' | base64 -d
    echo

# Bring up a local kind cluster running the same argocd module.
kind-up:
    tofu -chdir=tofu/kind init
    tofu -chdir=tofu/kind apply

# Tear down the local kind cluster.
kind-down:
    tofu -chdir=tofu/kind destroy

# Format check, tofu validate on every root/module, and manifest validation.
lint:
    tofu fmt -check -recursive tofu
    for d in tofu/modules/argocd tofu/scaleway tofu/kind; do tofu -chdir="$d" init -backend=false -input=false; tofu -chdir="$d" validate; done
    for w in gitops/workloads/*/; do kustomize build "$w" | kubeconform -strict -ignore-missing-schemas -summary; done
    kubeconform -strict -ignore-missing-schemas -summary gitops/apps/*.yaml

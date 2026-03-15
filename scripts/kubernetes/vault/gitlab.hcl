path "kv/data/devops/ca/root" {
capabilities = ["read"]
}

path "kv/data/devops/server/ssh/gitlab" {
capabilities = ["read"]
}

path "kv/data/devops/registry/*" {
capabilities = ["read"]
}

path "kv/metadata/devops/registry/*" {
capabilities = ["read", "list"]
}
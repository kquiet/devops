# This policy grants a user the ability to perform any action on any path
path "kv/data/devops/*" {
capabilities = ["read"]
}

path "kv/metadata/devops/*" {
capabilities = ["read", "list"]
}

path "sys/storage/raft/snapshot" {
  capabilities = ["read"]
}
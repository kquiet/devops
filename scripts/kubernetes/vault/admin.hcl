# This policy grants a user the ability to perform any action on any path
path "*" {
capabilities = ["create", "read", "update", "patch", "delete", "list", "sudo", "subscribe", "recover"]
}

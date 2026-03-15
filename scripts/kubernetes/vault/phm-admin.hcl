# 1. SECRET DATA: Create, Read, Update, Soft-Delete
path "kv/data/phm/*" {
  capabilities = ["create", "read", "update", "delete"]
}

# 2. METADATA & CONFIGURATION: List, Delete, Configure Settings
# - 'list': Enables UI navigation (Folder Explorer)
# - 'update': Allows configuring "Max Versions" & "CAS" settings for specific secrets
# - 'delete': Allows permanently deleting the metadata (the 'trash can' icon in UI)
path "kv/metadata/phm/*" {
  capabilities = ["list", "read", "update", "delete"]
}

# 3. VERSION CONTROL: Advanced Delete Operations
# Allows soft-deleting specific versions (e.g., delete only version 2)
path "kv/delete/phm/*" {
  capabilities = ["update"]
}

# Allows undeleting a soft-deleted version
path "kv/undelete/phm/*" {
  capabilities = ["update"]
}

# Allows permanently destroying a specific version (removing it from disk)
path "kv/destroy/phm/*" {
  capabilities = ["update"]
}
#!/bin/bash

# Configuration variables (these will be replaced by the install script)
backup_name="hashicorp_vault"
backup_to="/mnt/devops_backup/hashicorp_vault"
backup_keep_count=28

# Function for error handling
handle_error() {
    echo "ERROR: $1" >&2
    exit 1
}

# Function to backup data
backup_data() {
    VAULT_NAMESPACE="vault"
    VAULT_POD="vault-0"
    SNAPSHOT_FILENAME="backup_${backup_name}_$(date +%Y%m%d)_$(date +%H%M%S).snap"
    SNAPSHOT_PATH_IN_POD="/tmp/${SNAPSHOT_FILENAME}" # Use a temporary path in the pod

    echo "Starting Vault snapshot for ${VAULT_POD}..."

    # Step 1: Create the snapshot inside the pod using K8s auth
    # This command runs a small script inside the pod to securely authenticate and take the snapshot.
    kubectl exec -n "${VAULT_NAMESPACE}" "${VAULT_POD}" -- /bin/sh -c " \
      KUBE_SA_TOKEN=\$(cat /var/run/secrets/kubernetes.io/serviceaccount/token) && \
      export VAULT_TOKEN=\$(vault write -field=token auth/kubernetes/login role=snapshot jwt=\$KUBE_SA_TOKEN) && \
      vault operator raft snapshot save ${SNAPSHOT_PATH_IN_POD}"

    # Check if the snapshot command was successful
    if [ $? -ne 0 ]; then
      echo "Error: Failed to create Vault snapshot inside the pod. Aborting."
      return 1
    fi

    echo "Snapshot created successfully inside the pod."

    # Step 2: Copy the snapshot from the pod to the host
    kubectl cp "${VAULT_NAMESPACE}/${VAULT_POD}:${SNAPSHOT_PATH_IN_POD}" "${backup_to}/${SNAPSHOT_FILENAME}"

    # Check if the copy command was successful
    if [ $? -ne 0 ]; then
      echo "Error: Failed to copy snapshot from pod to host. Aborting."
      # Attempt to clean up the file in the pod anyway
      kubectl exec -n "${VAULT_NAMESPACE}" "${VAULT_POD}" -- rm "${SNAPSHOT_PATH_IN_POD}"
      return 1
    fi

    echo "Snapshot successfully copied to ${backup_to}/${SNAPSHOT_FILENAME}"

    # Step 3: Clean up the snapshot file inside the pod
    kubectl exec -n "${VAULT_NAMESPACE}" "${VAULT_POD}" -- rm "${SNAPSHOT_PATH_IN_POD}"
    echo "Cleaned up snapshot file from the pod."

    echo "Vault backup process complete."
}

# Function to remove old backups
remove_old_backups() {
    echo "Checking for old backups..."
    local backup_count=$(ls "${backup_to}"/backup_${backup_name}_[0-9]*_[0-9]*.snap 2>/dev/null | wc -l)

    while [ "$backup_count" -gt "$backup_keep_count" ]; do
        local oldest_backup=$(ls "${backup_to}"/backup_${backup_name}_[0-9]*_[0-9]*.snap | sort | head -n 1)
        rm -rf "$oldest_backup" || handle_error "Failed to remove old backup: $oldest_backup"
        echo "Removed old backup: $oldest_backup"
        backup_count=$((backup_count - 1))
    done
}

# Main function to run the backup process
run_backup() {
    echo "Backup script started"
    echo "Using configuration:"
    echo "  backup_name: $backup_name"
    echo "  backup_to: $backup_to"
    echo "  backup_keep_count: $backup_keep_count"

    backup_data

    remove_old_backups

    echo "Backup completed successfully"
}

# Run the backup process
run_backup

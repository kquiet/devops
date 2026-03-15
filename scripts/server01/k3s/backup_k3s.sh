#!/bin/bash

# Configuration variables (these will be replaced by the install script)
backup_name="k3s"
backup_src="/var/lib/rancher/k3s/server"
backup_to="/mnt/devops_backup/k3s"
backup_keep_count=2

# Function for error handling
handle_error() {
    echo "ERROR: $1" >&2
    exit 1
}

# Function to backup data
backup_data() {
    echo "Starting backup ${backup_name}..."
    tar --exclude="db/etcd" -czvf "${backup_to}/backup_${backup_name}_$(date +%Y%m%d)_$(date +%H%M%S).tar.gz" -C "$backup_src" "db" "token" || handle_error "Failed to backup ${backup_name} from $backup_src"
    echo "Backup ${backup_name} completed"
}

# Function to remove old backups
remove_old_backups() {
    echo "Checking for old backups..."
    local backup_count=$(ls "${backup_to}"/backup_${backup_name}_[0-9]*_[0-9]*.tar.gz 2>/dev/null | wc -l)

    while [ "$backup_count" -gt "$backup_keep_count" ]; do
        local oldest_backup=$(ls "${backup_to}"/backup_${backup_name}_[0-9]*_[0-9]*.tar.gz | sort | head -n 1)
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
    echo "  backup_src: $backup_src"
    echo "  backup_to: $backup_to"
    echo "  backup_keep_count: $backup_keep_count"

    backup_data

    remove_old_backups

    echo "Backup completed successfully"
}

# Run the backup process
run_backup

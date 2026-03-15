#!/bin/bash

# Configuration variables (these will be replaced by the install script)
scriptfile=$(realpath "$0")
workdir=$(dirname "$scriptfile")
backup_name="mariadb"
backup_from_container="mariadb"
backup_to="/mnt/devops_backup/mariadb"
env_file="${workdir}/.env"
backup_keep_count=7

# Function for error handling
handle_error() {
    echo "ERROR: $1" >&2
    exit 1
}

# Function to backup data
backup_data() {
    echo "Starting backup ${backup_name}..."
    source "${env_file}"
    docker exec ${backup_from_container} mariadb-dump -u root --password=${MARIADB_ROOT_PASSWORD} --all-databases | gzip > "${backup_to}/backup_${backup_name}_$(date -u +%Y%m%d)_$(date -u +%H%M%S).sql.gz" || handle_error "Failed to backup ${backup_name} from container ${backup_from_container}"
    echo "Backup ${backup_name} completed"
}

# Function to remove old backups
remove_old_backups() {
    echo "Checking for old backups..."
    local backup_count=$(ls "${backup_to}"/backup_${backup_name}_[0-9]*_[0-9]*.sql.gz 2>/dev/null | wc -l)

    while [ "$backup_count" -gt "$backup_keep_count" ]; do
        local oldest_backup=$(ls "${backup_to}"/backup_${backup_name}_[0-9]*_[0-9]*.sql.gz | sort | head -n 1)
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
    echo "  backup_from_container: $backup_from_container"
    echo "  backup_to: $backup_to"
    echo "  backup_keep_count: $backup_keep_count"

    backup_data

    remove_old_backups

    echo "Backup completed successfully"
}

# Run the backup process
run_backup

#!/bin/bash

# Configuration variables (these will be replaced by the install script)
backup_src="/opt/docker_volumes/nexus-repository"
backup_to="/mnt/devops_backup/nexus-repository"
backup_keep_count=2
docker_compose_path="/home/devops/git/devops/scripts/server03/nexus-repository/docker-compose.yaml"

docker_compose_start() {
    docker compose -f "${docker_compose_path}" start && echo "docker compose started"
}

docker_compose_stop() {
    docker compose -f "${docker_compose_path}" stop && echo "docker compose stopped"
}

cleanup() {
  echo "Running cleanup before exit"
  docker_compose_start
}

trap cleanup EXIT

# Function for error handling
handle_error() {
    echo "ERROR: $1" >&2
    exit 1
}

# Function to create backup directory
create_backup_directory() {
    local backup_dir="${backup_to}/$(date +%Y%m%d%H%M%S)"
    mkdir -p "$backup_dir" || handle_error "Failed to create backup directory: $backup_dir"
    echo "$backup_dir"
}

# Function to backup data
backup_data() {
    docker_compose_stop
    local backup_dir="$1"
    echo "Starting backup repository..."
    tar --exclude="nexus-data/blobs/*" -czvf "${backup_dir}/nexus-data.tar.gz" -C "$backup_src" "nexus-data" || handle_error "Failed to backup nexus-data from $backup_src/nexus-data"

    # Loop through each blob in the directory
    for subdir in "$backup_src/nexus-data/blobs"/*; do
    # Check if is a directory
    if [ -d "$subdir" ]; then
        local dirname="$(basename "$subdir")"
        tar -czvf "${backup_dir}/blobs-$dirname.tar.gz" -C "$backup_src" "nexus-data/blobs/$dirname" || handle_error "Failed to backup blobs/$dirname from $backup_src/nexus-data/blobs"
    fi
    done
    echo "Backup repository completed"
}

# Function to remove old backups
remove_old_backups() {
    echo "Checking for old backups..."

    # Get all backup directories sorted by name
    local all_backups=($(ls -d "${backup_to}"/[0-9]* 2>/dev/null | sort))
    local backup_count=${#all_backups[@]}

    if [ "$backup_count" -le "$backup_keep_count" ]; then
        echo "No old backups to remove. Current count: $backup_count, Keep count: $backup_keep_count"
        return
    fi

    # Calculate how many backups to remove
    local remove_count=$((backup_count - backup_keep_count))

    # Remove the oldest backups
    for ((i = 0; i < remove_count; i++)); do
        rm -rf "${all_backups[$i]}" || handle_error "Failed to remove old backup: ${all_backups[$i]}"
        echo "Removed old backup: ${all_backups[$i]}"
    done
}

# Main function to run the backup process
run_backup() {
    echo "Backup script started"
    echo "Using configuration:"
    echo "  backup_src: $backup_src"
    echo "  backup_to: $backup_to"
    echo "  backup_keep_count: $backup_keep_count"

    local backup_dir=$(create_backup_directory)
    echo "Created backup directory: $backup_dir"

    backup_data "$backup_dir"

    remove_old_backups

    echo "Backup completed successfully"
}

# Run the backup process
run_backup

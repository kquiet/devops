#!/bin/bash

# --- Configuration ---
SIZE_IN_MB="$1"
GITLAB_CONTAINER_NAME="gitlab"
CURRENT_STR=$(date +'%Y%m%d%H%M%S')
HOST_OUTPUT_FILE="over_size_projects_${SIZE_IN_MB}mb_${CURRENT_STR}.csv"

# Check if the size argument is provided
if [ -z "$SIZE_IN_MB" ]; then
  echo "Error: Please provide the size in MB as the first argument."
  echo "Usage: ./your_script_name.sh <size_in_mb>"
  exit 1
fi

docker exec "$GITLAB_CONTAINER_NAME" gitlab-rails runner "
  require 'csv'
  size_in_mb = ARGV[0].to_i
  size_in_bytes = size_in_mb * 1024 * 1024

  projects = Project.joins(:statistics).includes(:creator)
                    .where('project_statistics.repository_size > ?', size_in_bytes)
                    .order('project_statistics.repository_size DESC')

  columns = %w[web_url repository_size_mb creator_name created_at last_activity_at]

  # Write CSV to STDOUT
  csv_data = CSV.generate do |csv|
    csv << columns
    projects.each do |project|
      creator_name = project.creator ? project.creator.name : 'unknown'
      csv << [
        project.web_url,
        (project.statistics.repository_size.to_f / (1024 * 1024)).round(2),
        creator_name,
        project.created_at.strftime('%Y-%m-%d %H:%M:%SZ'),
        project.last_activity_at.strftime('%Y-%m-%d %H:%M:%SZ')
      ]
    end
  end
  puts csv_data
" -- "$SIZE_IN_MB" > "$HOST_OUTPUT_FILE"

echo "CSV file generated: $HOST_OUTPUT_FILE"

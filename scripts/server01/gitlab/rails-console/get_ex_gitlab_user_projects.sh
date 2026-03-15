#!/bin/bash

# User `puts Project.column_names` or `puts User.column_names`
# to see available attributes of model Project and User in the Rails console (`gitlab-rails console`)

# --- Configuration ---
# Path to your ex-users list file on the HOST
HOST_INPUT_FILE="$1"

# Name of your GitLab Docker container (e.g., 'gitlab' or from 'docker ps')
GITLAB_CONTAINER_NAME="gitlab"

# Paths for the input and output files INSIDE the container
CONTAINER_INPUT_FILE="/tmp/ex_gitlab_users_container.csv"

# Path for the final output CSV file on the HOST
CURRENT_STR=$(date +'%Y%m%d%H%M%S')
HOST_OUTPUT_FILE="ex_gitlab_user_projects_${CURRENT_STR}.csv"

# --- Script Logic ---

echo "Starting GitLab personal project retrieval for ex-users..."

# 1. Check if the host input file exists
if [ ! -f "$HOST_INPUT_FILE" ]; then
  echo "Error: Host input file '$HOST_INPUT_FILE' not found."
  exit 1
fi

# 2. Copy the input file to the container's /tmp directory
echo "Copying '$HOST_INPUT_FILE' to '$GITLAB_CONTAINER_NAME':'$CONTAINER_INPUT_FILE'..."
docker cp "$HOST_INPUT_FILE" "$GITLAB_CONTAINER_NAME":"$CONTAINER_INPUT_FILE"
if [ $? -ne 0 ]; then
  echo "Error: Failed to copy input file to container. Exiting."
  exit 1
fi
echo "Input file copied successfully."

# 3. Execute the Ruby script inside the container using gitlab-rails runner
echo "Executing Ruby script inside the container..."
docker exec -i "$GITLAB_CONTAINER_NAME" gitlab-rails runner - <<EOF > $HOST_OUTPUT_FILE
# --- Start of Ruby Script (Embedded) ---
require 'csv'

# Define the paths for input and output files INSIDE the container
CONTAINER_INPUT_FILE = "${CONTAINER_INPUT_FILE}"

ex_usernames = []

# Read usernames from the specified input file inside the container
begin
  CSV.foreach(CONTAINER_INPUT_FILE) do |row|
    ex_usernames << row[0].strip if row[0]
  end
rescue Errno::ENOENT
  warn "Error: Input file '#{CONTAINER_INPUT_FILE}' not found inside container."
  exit 1
rescue => e
  warn "Error reading input file '#{CONTAINER_INPUT_FILE}' inside container: #{e.message}"
  exit 1
end


# Define the headers for the output CSV
headers = %w[project_web_url ex_username project_created_at project_last_activity_at is_personal_project]

# Prepare CSV content
output_csv_data = CSV.generate(headers: true) do |csv|
  csv << headers

  if ex_usernames.empty?
    warn "No ex-usernames found in '#{CONTAINER_INPUT_FILE}'."
  end

  ex_usernames.each do |username|
    user = User.find_by_username(username.to_s) # .to_s ensures it's a string

    if user
      personal_projects = Project.where(creator_id: user.id)
      if personal_projects.any?
        personal_projects.each do |project|
          is_personal_project = project.web_url.include?(username)
          csv << [
            project.web_url,
            username,
            project.created_at.strftime('%Y-%m-%d %H:%M:%SZ'),
            project.last_activity_at.strftime('%Y-%m-%d %H:%M:%SZ'),
            is_personal_project
          ]
        end
      end
    else
      warn "User '#{username}' not found in GitLab. Skipping projects for this user."
    end
  end
end

# Write the CSV data to the specified output file inside the container
puts output_csv_data
EOF

if [ $? -ne 0 ]; then
  echo "Error: Ruby script execution failed inside container. Check container logs for details."
  # Proceed to cleanup, as input file might still be there
fi
echo "Ruby script execution completed."


# 4. Delete the copied input file from the container's /tmp directory
echo "Cleaning up temporary files in container..."
docker exec "$GITLAB_CONTAINER_NAME" rm -f "$CONTAINER_INPUT_FILE"
echo "Cleanup complete."

echo "Process finished. Check '$HOST_OUTPUT_FILE' for the list of personal projects."
echo "Any warnings or errors from the Ruby script (e.g., user not found) will be printed to your console."


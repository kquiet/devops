#!/bin/bash
GITLAB_CONTAINER_NAME="gitlab"
CURRENT_STR=$(date +'%Y%m%d%H%M%S')
docker exec -i ${GITLAB_CONTAINER_NAME} gitlab-rails runner - <<EOF > gitlab_users_${CURRENT_STR}.csv
# export_users.rb script content here
require 'csv'
headers = %w[username created_at last_activity_on]
email_suffix = '@zoo.internal'
data = CSV.generate(headers: true) do |csv|
  csv << headers
  User.where("email ILIKE ?", "%#{email_suffix}").find_each do |user|
    csv << [
      user.username,
      user.created_at.strftime('%Y-%m-%d %H:%M:%SZ'),
      user.last_activity_on&.strftime('%Y-%m-%d %H:%M:%SZ')
    ]
  end
end
puts data
EOF

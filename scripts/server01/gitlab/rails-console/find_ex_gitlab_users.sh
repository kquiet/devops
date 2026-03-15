#!/bin/bash

# Define the path to your input CSV file
INPUT_CSV=$1

# Define the path to the output file where non-company usernames will be stored
CURRENT_STR=$(date +'%Y%m%d%H%M%S')
OUTPUT_FILE="ex_gitlab_users_${CURRENT_STR}.csv"

# Define the path to your test script
# Ensure test_user.sh is executable (e.g., chmod +x test_user.sh)
TEST_SCRIPT="../../../ldap/list_ldap_attributes.sh"

# --- Script Start ---

echo "Starting user check process..."
echo "Output file for non-company users: $OUTPUT_FILE"

# Clear the output file if it already exists, or create a new one
> "$OUTPUT_FILE"

# Check if the input CSV file exists
if [ ! -f "$INPUT_CSV" ]; then
  echo "Error: Input CSV file '$INPUT_CSV' not found."
  exit 1
fi

# Check if the test_user.sh script exists and is executable
if [ ! -f "$TEST_SCRIPT" ] || [ ! -x "$TEST_SCRIPT" ]; then
  echo "Error: Test script '$TEST_SCRIPT' not found or not executable."
  echo "Please ensure '$TEST_SCRIPT' exists and has execute permissions (e.g., chmod +x $TEST_SCRIPT)."
  exit 1
fi

# Read the CSV file line by line, skipping the header (first line)
# IFS=, sets the Internal Field Separator to comma for read -r
# tail -n +2 starts reading from the second line
while IFS=, read -r username created_at last_activity_on; do
  # Skip empty lines that might result from trailing newlines in the CSV
  if [ -z "$username" ]; then
    continue
  fi

  echo "Checking user: $username"

  # Step 2: Execute 'test_user.sh <USERNAME>'
  # Use "$username" to properly handle usernames with spaces (though unlikely in Gitlab)
  "$TEST_SCRIPT" "$username" | grep sAMAccountName

  # Step 3: Check the exit result of step 2
  # $? holds the exit status of the last executed command
  # A non-zero exit code indicates failure (user not in company, as per your requirement)
  if [ $? -ne 0 ]; then
    echo "  -> User '$username' is NOT in the company. Appending to '$OUTPUT_FILE'."
    # Step 4: Append the username to the output file
    echo "$username" >> "$OUTPUT_FILE"
  else
    echo "  -> User '$username' is in the company."
  fi
  sleep 1
done < <(tail -n +2 "$INPUT_CSV")

echo "Processing complete. Check '$OUTPUT_FILE' for non-company users."


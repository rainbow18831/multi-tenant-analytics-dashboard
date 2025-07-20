#!/bin/bash

# Check for start and end dates as arguments
if [ "$#" -ne 2 ]; then
    echo "Usage: $0 <start_date> <end_date>"
    echo "Dates should be in YYYY-MM-DD format."
    exit 1
fi

start_date=$1
end_date=$2


# Create or clear the file
echo "Initial content" > file.txt
git add file.txt
git commit -m "Initial commit"

# Set proper commit date format
initial_datetime="$start_date 12:00:00"
GIT_COMMITTER_DATE="$initial_datetime" git commit --amend --no-edit --date "$initial_datetime"

# Convert start and end dates to seconds
start_seconds=$(date -d "$start_date" +%s)
end_seconds=$(date -d "$end_date" +%s)

current_seconds=$start_seconds
while [ "$current_seconds" -le "$end_seconds" ]; do
    # Get the first day of the current month
    first_day=$(date -d "@$current_seconds" +%Y-%m-01)

    # Calculate last day of this month
    next_month=$(date -d "$first_day +1 month" +%Y-%m-01)
    last_day=$(date -d "$next_month -1 day" +%d)

    # Skip invalid months
    if [[ -z "$last_day" || "$last_day" -eq 0 ]]; then
        echo "Warning: Skipping invalid month at $first_day"
        current_seconds=$(date -d "$first_day +1 month" +%s)
        continue
    fi

    # Generate 6 random commit days in this month
    for ((j=0; j<2; j++)); do
        random_day=$((1 + RANDOM % last_day))
        commit_date=$(date -d "$first_day +$((random_day - 1)) days" +%Y-%m-%d)

        if [[ "$commit_date" > "$end_date" ]]; then
            continue
        fi

        commit_datetime="$commit_date 12:00:00"
        echo "Committing on: $commit_datetime"

        echo "Update for $commit_date" >> file.txt
        git add file.txt
        git commit -m "Commit for $commit_date"
        GIT_COMMITTER_DATE="$commit_datetime" git commit --amend --no-edit --date "$commit_datetime"
    done

    # Move to next month
    current_seconds=$(date -d "$first_day +1 month" +%s)
done

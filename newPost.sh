#!/usr/bin/env bash

# Prompt for folder name
read -rp "Enter folder name: " folder_name
mkdir -p "$folder_name" || { echo "Failed to create folder"; exit 1; }

# Prompt for title
read -rp "Enter title: " title

# Prompt for tags (comma-separated)
read -rp "Enter tags (comma separated): " tags_input

# Convert tags to array format ['tag1', 'tag2', ...]
# Remove spaces, split by comma, and wrap each tag in single quotes
IFS=',' read -ra tags_array <<< "$tags_input"
formatted_tags=$(printf "'%s', " "${tags_array[@]}")
formatted_tags="[${formatted_tags%, }]"

# Get current date at midnight in ISO8601 with timezone offset (-04:00)
current_date=$(date +"%Y-%m-%dT00:00:00%:z")

# Create index.md with Hugo front matter
cat > "$folder_name/index.md" <<EOF
---
title: '$title'
date: $current_date
draft: false
author: Keith Henderson
tags: $formatted_tags
---
EOF

echo "index.md created in $folder_name/"


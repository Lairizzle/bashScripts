#!/bin/bash

# Prompt for repo name
read -p "Enter the name of the new repository: " REPO_NAME

# Prompt for commit message
read -p "Enter the commit message: " COMMIT_MSG

# Prompt for visibility (public/private)
read -p "Should the repository be public or private? (public/private): " VISIBILITY

# Initialize git and commit
git init
git add .
git commit -m "$COMMIT_MSG"

# Create GitHub repo and push
gh repo create "$REPO_NAME" --$VISIBILITY --source=. --remote=upstream --push

echo "Repository '$REPO_NAME' created and pushed to GitHub as '$VISIBILITY'."


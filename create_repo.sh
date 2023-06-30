#!/bin/bash

# Prompt for repository name
read -p "Enter the repository name: " REPO_NAME
read -p "Enter public or private: " VIS

# Check if repository name is provided
if [ -z "$REPO_NAME" ]; then
  echo "Repository name cannot be empty!"
  exit 1
fi

# Check if repository VIS is provided
if [ -z "$VIS" ]; then
  echo "Repository VIS cannot be empty!"
  exit 1
fi

# Create a new repository using GitHub CLI
echo "Creating a new GitHub repository named $REPO_NAME"
gh repo create $REPO_NAME --$VIS --confirm

# Navigate to the repository folder
cd $REPO_NAME

# Create an empty README file
echo "# $REPO_NAME" > README.md

# Stage, commit, and push the changes
git add .
git commit -m "Initial commit"
git push -u origin main

# Print success message
echo "Repository $REPO_NAME created successfully and README.md file pushed to GitHub!"

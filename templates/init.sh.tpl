#!/bin/bash
set -e

# Create project directory
mkdir -p ${project_name}
cd ${project_name}

echo "Initializing project ${project_name}..."

# Clone repositories
for repo in ${jsonencode(repositories)}; do
  echo "Cloning $repo..."
  git clone "git@github.com:${repo_org}/$repo.git"
done

# Generate VS Code workspace file
echo "Setting up VS Code workspace..."
cp "./${base_repo}/workspace.json" "./${project_name}.code-workspace"

# Configure git settings for each repository
echo "Configuring git settings..."
for dir in */; do
  cd "$dir"
  git config pull.rebase true
  git config branch.autosetuprebase always
  cd ..
done

# Execute custom initialization if provided
${custom_script}

echo "Project initialization complete!"
#!/bin/bash
set -e

# Create project directory
mkdir -p ${project_name}
cd ${project_name}

echo "Initializing project ${project_name}..."

# Clone repositories
%{ for repo in repositories ~}
echo "Cloning ${repo}..."
git clone "git@github.com:${repo_org}/${repo}.git" ../${repo}" || true
%{ endfor ~}

# Execute custom initialization if provided
${custom_script}

echo "Project initialization complete!"
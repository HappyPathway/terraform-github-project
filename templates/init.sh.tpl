#!/bin/bash
set -e

echo "Initializing project ${project_name}..."

# Clone repositories
%{ for repo in repositories ~}
git clone "git@github.com:${repo_org}/${repo}.git" "../${repo}" || true
%{ endfor ~}

# Execute custom initialization if provided
${custom_script}

echo "Project initialization complete!"

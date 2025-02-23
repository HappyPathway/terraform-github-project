#!/usr/bin/env bash
# This script requires execution permission. Run:
# chmod +x scripts/init.sh

set -e

echo "Initializing project ${project_name}..."

# Clone repositories
%{ for repo in repositories ~}
git clone "git@github.com:${repo_org}/${repo.name}.git" "../${repo.name}" || true
%{ endfor ~}

echo "Project initialization complete!"

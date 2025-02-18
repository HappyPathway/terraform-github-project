#!/bin/bash

echo "Initializing ${project_name} project..."

# Clone all repositories
%{for repo in repositories~}
git clone ${repo} ../${repo} || echo "Repository ${repo} already exists."
%{endfor~}

echo "Repository cloning complete."
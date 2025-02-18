#!/bin/bash

echo "Initializing ${project_name} project..."

# Clone all repositories
%{for repo in repositories~}
git clone ${repo} ..
%{endfor~}

echo "Repository cloning complete."
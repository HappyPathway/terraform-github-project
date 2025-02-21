#!/bin/bash

# Default to 24 hours if no argument is provided
HOURS=${1:-24}
ORG=${2:-$(gh api user/orgs --jq '.[0].login')}

echo "Listing repositories created in the last $HOURS hours for organization: $ORG"

# Calculate the cutoff time in ISO 8601 format
CUTOFF=$(date -v-${HOURS}H -u +"%Y-%m-%dT%H:%M:%SZ")

# List repositories and filter by creation date
gh api \
  --paginate \
  "orgs/$ORG/repos" \
  --jq ".[] | select(.created_at >= \"$CUTOFF\") | {name: .name, created_at: .created_at, private: .private}" | \
  jq -r '. | "\(.created_at)\t\(.name)\t\(.private)"' | \
  sort
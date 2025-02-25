# Documentation Source Path Handling

## Overview

The project now handles documentation sources with proper organization separation, allowing documentation to be pulled from multiple GitHub organizations while maintaining clear path structures.

## Path Structure

Documentation repositories are stored following this pattern:
```
${docs_base_path}/{source_org}/{source_repo}
```

For example:
```
~/.gproj/docs/hashicorp/terraform/
~/.gproj/docs/golang/go/
```

This structure allows:
- Clear separation between different organizations' documentation
- Multiple repos with the same name from different orgs
- Consistent path resolution across all components

## Component Behavior

### 1. gproj Script

The script now:
- Handles both HTTPS and SSH URLs for cloning
- Falls back to HTTPS if SSH fails
- Extracts org/repo information from:
  ```
  - git@github.com:org/repo.git
  - https://github.com/org/repo
  - org/repo
  ```
- Maintains consistent paths regardless of URL format
- Preserves specified tags/branches when cloning

### 2. VS Code Workspace

The workspace configuration:
- Uses the same path structure as the gproj script
- Properly extracts org/repo from repository URLs
- Maps documentation folders using the standardized path structure
- Maintains proper folder naming in the workspace

### 3. Configuration Files

#### .gproj Configuration
```json
{
  "project_name": "example",
  "repo_org": "myorg",
  "docs_base_path": "~/.gproj/docs",
  "documentation_sources": [
    {
      "repo": "hashicorp/terraform",
      "name": "docs/terraform",
      "path": "website/docs",
      "tag": "v1.5.0"
    }
  ]
}
```

Note: The `docs_base_path` is now kept simple - the source repository's organization provides the structure.

## Practical Example

For a documentation source configured as:
```hcl
documentation_sources = [
  {
    repo = "hashicorp/terraform"
    name = "docs/terraform"
    path = "website/docs"
    tag  = "v1.5.0"
  }
]
```

The system will:
1. Clone from either:
   - `git@github.com:hashicorp/terraform.git` (SSH, preferred)
   - `https://github.com/hashicorp/terraform` (HTTPS fallback)

2. Store the repository at:
   `~/.gproj/docs/hashicorp/terraform`

3. Create a VS Code workspace folder mapping:
   ```json
   {
     "name": "docs/terraform",
     "path": "~/.gproj/docs/hashicorp/terraform"
   }
   ```

## Authentication

Repository cloning now:
1. Attempts SSH first (requires configured SSH keys)
2. Falls back to HTTPS if SSH fails
3. Supports authentication through:
   - SSH keys (preferred)
   - HTTPS credentials
   - Git credential helpers

## Improvements Over Previous Version

- No longer mixes project organization with documentation sources
- Properly handles SSH and HTTPS URLs
- Maintains correct organization separation
- Avoids path conflicts between different organizations
- More resilient authentication handling
- Consistent path structure across all components

## Limitations

1. SSH keys must be properly configured for SSH access
2. HTTPS fallback may require credential configuration
3. Repository names must be unique within their respective organizations
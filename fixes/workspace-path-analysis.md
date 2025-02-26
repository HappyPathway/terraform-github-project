# Workspace Path Analysis

## Current Limitation Discovered
VS Code workspace files cannot expand environment variables or the tilde (~) character. This means paths like `~/.gproj/docs` won't work in the workspace file. We need to use relative paths instead.

## Proposed Directory Structure

Given a project structure like:
```
/parent-directory/
├── my-project/                 # Base repository
│   └── .gproj                 # Config file
├── my-project-docs/           # Documentation repositories
│   ├── terraform/
│   │   └── website/docs/      # Actual documentation content
│   └── kubernetes/
│       └── docs/             # Actual documentation content
└── other-repos/              # Other project repositories
```

### gproj Script (Clone Behavior)
- Should still use .gproj config's docs_base_path for cloning
- Clones documentation repos into `../my-project-docs/{repo_name}`
- Example: `../my-project-docs/terraform` for hashicorp/terraform repo

### VS Code Workspace (Path Resolution)
- Must use relative paths from the base repo
- Example paths in workspace file:
```json
{
  "folders": [
    {
      "name": "my-project",
      "path": "."
    },
    {
      "name": "docs/terraform",
      "path": "../my-project-docs/terraform/website/docs"
    }
  ]
}
```

## Required Changes

1. **Project Structure**
   - Base repository remains in its location
   - Create `docs` directory next to base repo, if it doesn't already exist.
   - Clone documentation repos into this directory

2. **Path Construction**
   - VS Code workspace: Use relative paths (`../`)
   - gproj script: Convert docs_base_path to project-relative path

3. **Configuration Updates Needed**
   - .gproj config needs to reflect new path structure
   - Scripts must handle path conversion
   - Workspace generation must use relative paths

## Example Configuration

For a documentation source:
```hcl
{
  repo = "hashicorp/terraform"
  name = "docs/terraform"
  path = "website/docs"
  tag  = "v1.5.0"
}
```

Should result in:
1. Clone to: `../my-project-docs/terraform`
2. Workspace mapping:
```json
{
  "name": "docs/terraform",
  "path": "../my-project-docs/terraform/website/docs"
}
```

## Implementation Notes

1. Keep gproj clone behavior, but change target directory
2. Update workspace path construction to:
   - Always use relative paths
   - Properly handle parent directory navigation
   - Account for subfolder paths

3. No changes needed to:
   - SSH/HTTPS handling
   - Authentication mechanism
   - Documentation source format
   - Display names in VS Code

## Testing Considerations

Test cases should verify:
1. Base repo and docs directory relationship
2. Relative path resolution
3. Subfolder navigation
4. Path collision handling
5. Cross-platform path handling (Windows/Unix)

Remember: The clone operation stays simple, we just change where we put the repos, and the workspace file uses relative paths to find them.
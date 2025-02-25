# gproj Script Documentation

## Overview
The `gproj` script provides project and documentation management capabilities with enhanced URL handling and authentication fallbacks.

## Command Line Interface
```
gproj [options]

Options:
  --debug              Show current configuration
  --nuke              Remove repositories (creates backup branches first)
  --branch BRANCH     Branch name for push operations
  --exclude REPOS     Space-separated list of repos to exclude
  --commit           Create commits in repositories
  --push             Push changes to remote
  --message, -m MSG   Commit message (required with --commit)
  --files FILES      Space-separated list of files to commit
```

## Features

### Project Repository Management
- Clones/updates project repositories
- Creates backup branches before destructive operations
- Handles Git operations across multiple repositories
- Supports SSH with HTTPS fallback
- Respects repository organization structure

### Documentation Source Management
- Maintains proper organization separation
- Supports multiple repository URL formats
- Handles authentication fallback gracefully
- Preserves specified tags/branches
- Maintains consistent paths across components

### Git Operations
- Parallel repository operations (limited to 5 concurrent tasks)
- Selective repository operations with --exclude
- Batch commits across repositories
- Branch management and backup creation
- Support for specific file operations

### Authentication Methods
1. SSH (primary)
   - Uses configured SSH keys
   - Requires proper key setup
2. HTTPS (fallback)
   - Used when SSH fails
   - Supports credential helpers
   - Compatible with token authentication

## Configuration (.gproj file)
```json
{
  "project_name": "required",
  "repo_org": "required",
  "github_host": "optional, defaults to github.com",
  "docs_base_path": "required",
  "documentation_sources": [],
  "repositories": []
}
```

## Error Handling
- SSH authentication failures trigger HTTPS fallback
- Clear error messages with ✅/❌ indicators
- Parallel operation failure tracking
- Repository-specific error reporting
- Non-blocking documentation source failures

## Best Practices
1. Configure SSH keys for best performance
2. Use backup branches before destructive operations
3. Group related commits across repositories
4. Verify documentation paths in VS Code workspace
5. Keep .gproj configuration in version control
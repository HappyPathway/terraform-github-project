# Workspace Paths Analysis and Fix Plan

## Path Types and Their Handling

1. Repository References
   - Always use relative paths: "../repo-name"
   - Example: ../terraform-provider-smartprompt

2. Documentation Source References
   - Always use ${userHome}/.gproj/docs/[name]
   - Physical location matches workspace reference
   - Example: 
     - Clone to: ~/.gproj/docs/openai-python
     - Reference as: ${userHome}/.gproj/docs/openai-python

3. Workspace File References
   - Keep original paths exactly as provided
   - Used for additional references to external folders
   - Example: ../providers/terraform-provider-google/website/docs/r

## Implementation Details

1. Order of Path Processing:
```hcl
workspace_folders = distinct(concat(
  # 1. Repository paths (always relative)
  [for repo in var.repositories : {
    name = repo.name
    path = "../${repo.name}"
  }],
  
  # 2. Documentation folders (always use ${userHome}/.gproj/docs)
  [for source in var.documentation_sources : {
    name = replace(source.name, "^docs/+", "")
    path = "${userHome}/.gproj/docs/${replace(source.name, "^docs/+", "")}"
  }],
  
  # 3. Workspace files (keep original paths)
  var.workspace_files
))
```

2. Example Configuration:
```jsonc
{
  "folders": [
    // Repository references
    {"name": "smartprompt", "path": "../smartprompt"},
    {"name": "smartprompt-api", "path": "../smartprompt-api"},
    
    // Documentation sources (cloned docs)
    {"name": "openai-python", "path": "${userHome}/.gproj/docs/openai-python"},
    {"name": "openai-go", "path": "${userHome}/.gproj/docs/openai-go"},
    
    // Additional workspace references
    {"name": "providers/google/resources", "path": "../providers/terraform-provider-google/website/docs/r"}
  ]
}
```

## Usage Guidelines

1. For documentation repositories:
   - Use documentation_sources when you want to clone and reference docs
   - They will be cloned to ~/.gproj/docs
   - Referenced in workspace using ${userHome}/.gproj/docs

2. For existing external folders:
   - Use workspace_files when referencing existing paths
   - Paths will be used exactly as provided
   - No automatic cloning or management

3. For project repositories:
   - Always referenced relatively as ../repo-name
   - Automatically included from repositories variable

## Validation and Testing

1. Path Consistency Checks:
   - Documentation paths should always start with ${userHome}/.gproj/docs
   - Repository paths should always be relative (../)
   - Workspace file paths should match exactly as provided

2. Test Cases:
   - Test documentation source cloning and path resolution
   - Verify repository path generation
   - Validate workspace file path preservation
   - Check for path collisions and duplicates
   - Ensure proper escaping of special characters

3. Error Handling:
   - Invalid path formats should fail validation
   - Missing required path components should be caught
   - Path collisions should raise errors
   - Invalid documentation source configurations should fail gracefully

## Maintenance

1. Regular Updates:
   - Check for path validity during repository updates
   - Verify documentation source availability
   - Update paths when repository structure changes

2. Monitoring:
   - Track failed documentation source clones
   - Monitor workspace file availability
   - Log path resolution issues

3. Documentation:
   - Keep path handling documentation updated
   - Document any special path requirements
   - Maintain examples of valid configurations
# Changelog

## [Unreleased] - 2024-02-21

### Fixed
- Fixed handling of empty repository lists in all module outputs to prevent errors when no repositories are specified
- Updated GitHub provider version to ~> 6.2 across all examples and root module
- Fixed map to list conversion issues in repository_files.tf by using values() function
- Made all repositories public by default since GitHub Pro is not available
- Removed functionality that required GitHub Pro subscription
- Ensured all test cases include required variables: project_prompt, repo_org, and project_name

### Changed
- Simplified module outputs to use maps instead of lists for file outputs
- Updated file handling in copilot, development, infrastructure, quality, and security modules
- Standardized branch name references to "main"
- Improved error handling in modules when no repositories are specified

### Technical Details
- Module output changes:
  - Changed file outputs from lists to maps for better null handling
  - Added length checks before accessing repositories[0]
  - Updated template references to use .tpl extension consistently
  - Simplified file content generation
- Repository file handling:
  - Updated base_module_files to use values() for map to list conversion
  - Fixed copilot file filtering logic
  - Improved README.md template handling
- Provider version updates:
  - Root module: ~> 6.2
  - Django example: ~> 6.2
  - Infrastructure example: ~> 6.0
  - Java microservices: ~> 6.2
  - Minimal example: ~> 6.2
  - Multi-repo example: ~> 6.0
  - Multi-tier webapp: ~> 6.2
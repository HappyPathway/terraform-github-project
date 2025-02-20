# Minimal GitHub Project Configuration Example

This example shows the minimum required configuration for setting up a GitHub project with:
- A base repository
- One project repository
- Prompts configured for both repositories

## Required Variables
- `project_name` - Name of the project, used for base repository
- `repo_org` - GitHub organization name
- `project_prompt` - Main project prompt content

## Default Settings Applied

### Base Repository
- Repository visibility: private
- Branch protection: enabled
  - Requires pull requests
  - 1 approving review
  - Stale review dismissal
  - Code owner reviews required
  - Linear history required
- Git settings:
  - Squash merges allowed
  - Merge commits disabled
  - Branch deletion on merge
- Features enabled:
  - Issues
  - Wiki
  - Projects
- Security:
  - Vulnerability alerts enabled
  - Branch protection enforced for admins

### Project Repositories
- Same defaults as base repository
- Inherits branch protection settings
- Prompt files stored in `.github/prompts/` directory

## Usage

```hcl
module "github_project" {
  source = "../../"

  project_name    = "my-project"
  repo_org        = "my-org"
  project_prompt  = "This is the main project prompt that will be used across repos"

  repositories = [
    {
      name   = "service-a"
      prompt = "Service A specific prompt"
    }
  ]

  base_repository = {}
}
```
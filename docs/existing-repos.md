# Managing Existing Repositories

This guide explains how to use the module to manage existing repositories in your organization.

## Example Configuration

```hcl
module "existing_project" {
  source = "path/to/terraform-github-project"
  project_name = "existing-project"
  
  project_prompt = "Managing existing repositories in our organization"
  
  repositories = [
    {
      name = "existing-repo-1"
      create_repo = false  # This tells Terraform to manage an existing repository
      prompt = "First existing repository"
      github_repo_description = "Managing an existing repository"
      github_repo_topics = ["existing", "managed"]
    },
    {
      name = "existing-repo-2"
      create_repo = false
      prompt = "Second existing repository"
      github_repo_topics = ["existing", "managed"]
    }
  ]
}
```

## Important Considerations

- Set `create_repo = false` for existing repositories
- The module will only manage the specified settings
- Existing repository content remains unchanged
- Branch protection rules can be applied to existing repositories
- Existing repository settings will be overwritten by the module configuration
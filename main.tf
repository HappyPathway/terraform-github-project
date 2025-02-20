# Repositories data source
data "github_repository" "existing_repos" {
  for_each  = { for repo in var.repositories : repo.name => repo if try(repo.create_repo, true) == false }
  full_name = "${coalesce(each.value.repo_org, var.repo_org)}/${each.key}"
}

# Base repository locals
locals {
  base_repository = merge({
    name = var.project_name  # Ensure name is always set
    description = "Base repository for ${var.project_name} project"
    topics = ["project-base"]
    visibility = "private"
    has_issues = true
    has_wiki = true
    has_projects = true
    enable_branch_protection = true
    create_codeowners = true
    force_name = true  # Ensure consistent naming without date suffix
    create_repo = true
    branch_protection = {
      enforce_admins = true
      required_linear_history = true
      require_conversation_resolution = true
      required_approving_review_count = 1
      dismiss_stale_reviews = true
      require_code_owner_reviews = true
    }
    managed_extra_files = concat([
      {
        path    = ".github/prompts/project.prompt.md"
        content = var.project_prompt
      },
      {
        path    = ".github/copilot-instructions.md"
        content = coalesce(var.copilot_instructions, local.generated_copilot_instructions)
      },
      {
        path    = ".vscode/extensions.json"
        content = jsonencode({
          recommendations = local.recommended_extensions
        })
      },
      {
        path    = ".vscode/settings.json"
        content = jsonencode({
          "editor.formatOnSave": true,
          "editor.rulers": [80, 120],
          "[terraform]": {
            "editor.defaultFormatter": "hashicorp.terraform",
            "editor.formatOnSave": true,
            "editor.formatOnSaveMode": "file"
          },
          "files.associations": {
            "*.tfvars": "terraform",
            "*.tftest.hcl": "terraform"
          }
        })
      }
    ], var.base_repository.managed_extra_files != null ? var.base_repository.managed_extra_files : [])
  }, { for k, v in var.base_repository : k => v if k != "managed_extra_files" })
}
# Base repository files configuration
locals {
  # Core repository files for all repos
  standard_files = [
    {
      name = "README.md",
      content = templatefile("${path.module}/templates/README.md", {
        project_name = var.project_name
        description  = coalesce(try(var.base_repository.description, ""), var.project_name, "")
        repo_org     = var.repo_org
        repositories = [
          for repo in var.repositories : {
            repo             = repo.name
            repo_description = lookup(repo, "description", "${var.project_name}::${repo.name}") # Ensure empty string if null
          }
        ]
      })
    },
    {
      name = ".github/CODEOWNERS",
      content = templatefile("${path.module}/templates/CODEOWNERS", {
        codeowners = var.project_owners
      })
    },
    {
      name    = ".github/pull_request_template.md",
      content = file("${path.module}/templates/pull_request_template.md")
    }
  ]

  # Project prompt file (for base repo only)
  project_prompt_file = [
    {
      content = var.project_prompt
      name    = ".github/prompts/${var.project_name}.prompt.md"
    }
  ]

  # VS Code workspace configuration from development_environment module
  workspace_config_files = [
    for file in module.development_environment.files :
    {
      name    = file.name
      content = file.content
    }
  ]

  # Module files from various feature modules - keep original paths from modules
  base_module_files = concat(
    module.security.files,
    module.development.files,
    module.infrastructure.files,
    module.quality.files,
    module.copilot.files,
    [
      {
        name = "scripts/projg",
        content = templatefile("${path.module}/templates/project_git_manager.py.tpl", {
          project_name = var.project_name
          repo_org     = var.repo_org
          repositories = jsonencode([
            for repo in var.repositories :
            {
              name        = repo.name
              description = lookup(repo, "description", "${var.project_name}::${repo.name}") # Ensure empty string if null
            }
          ])
        })
      },
      {
        name    = "scripts/requirements.txt",
        content = file("${path.module}/templates/requirements.txt")
      }
    ]
  )

  # Copilot prompts - repo-specific prompts only
  repo_copilot_prompts = {
    for name, repo in local.project_repositories : name => [
      {
        name    = ".github/prompts/${name}.prompt.md"
        content = repo.prompt == null ? try(repo.description, "Repository-specific prompt for ${name}") : repo.prompt
      }
    ]
  }

  # Handle managed extra files for base repo
  extra_repo_files = local.base_repo_config.managed_extra_files == null ? [] : [
    for file in local.base_repo_config.managed_extra_files : {
      name    = file.path
      content = file.content
    }
  ]

  # Base repository files module (gets all module files and base config)
  repository_files = concat(
    local.standard_files,
    local.project_prompt_file,
    local.extra_repo_files,
    local.base_module_files,
    local.workspace_config_files
  )

  # Project repository files module (gets only repo-specific files)
  project_repository_files = {
    for name, repo in local.project_repositories : name => concat(
      local.standard_files,
      local.repo_copilot_prompts[name] # Only this repo's specific prompt
    )
  }
}

# Base repository files module (gets all module files and base config)
module "base_repository_files" {
  source = "./modules/repository_files"

  repository = module.base_repo.github_repo.name
  branch     = module.base_repo.default_branch
  files      = local.repository_files
  mkfiles    = var.mkfiles

  depends_on = [module.base_repo]
}

# Project repository files module (gets only repo-specific files)
module "project_repository_files" {
  source = "./modules/repository_files"
  for_each = {
    for repo in var.repositories : repo.name => repo
  }

  repository = each.key
  branch     = module.project_repos[each.key].default_branch
  files      = local.project_repository_files[each.key]
  mkfiles    = var.mkfiles

  depends_on = [module.project_repos]
}
# Base repository files configuration
locals {
  # Core repository files for all repos
  standard_files = [
    {
      name = "README.md",
      content = templatefile("${path.module}/templates/README.md", {
        project_name = var.project_name
        description  = try(var.base_repository.description, "")
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
    {
      name = "${var.project_name}.code-workspace"
      content = jsonencode({
        folders  = local.workspace_folders,
        settings = module.development_environment.workspace_config.settings
        extensions = {
          recommendations = module.development_environment.workspace_config.extensions.recommended
        }
        tasks   = module.development_environment.workspace_config.tasks
        launch = {
          version        = "0.2.0"
          configurations = module.development_environment.workspace_config.launch
        }
      })
    }
  ]

  # Module files reorganized
  base_module_files = [
    for file in concat(
      module.security.files,
      module.development.files,
      module.infrastructure.files,
      module.quality.files,
      module.development_environment.files
    ) : {
      name    = ".github/prompts/${file.name}"
      content = file.content
    }
  ]

  # Copilot files for all repos
  copilot_files = [
    for file in module.copilot.files : {
      name    = ".github/prompts/${var.project_name}.copilot.md"
      content = file.content
    }
  ]

  # Handle managed extra files for base repo
  extra_repo_files = local.base_repo_config.managed_extra_files == null ? [] : [
    for file in local.base_repo_config.managed_extra_files : {
      name    = file.path
      content = file.content
    }
  ]

  # Repository-specific prompts
  repo_specific_prompt_files = {
    for name, repo in local.project_repositories : name => [
      {
        name    = ".github/prompts/${name}.prompt.md"
        content = trimspace(coalesce(
          try(repo.prompt, null),
          try(repo.description, "Repository-specific prompt for ${name}")
        ))
      }
    ]
  }
}

# Base repository files module
module "base_repository_files" {
  source = "./modules/repository_files"

  repository = module.base_repo.github_repo.name
  branch     = module.base_repo.default_branch
  files = concat(
    local.standard_files,
    local.project_prompt_file, # Project prompt only goes to base repo
    local.extra_repo_files,
    local.base_module_files,
    local.copilot_files,
    [{
      name    = "init.sh",
      content = local.init_script_content
    }],
    local.workspace_config_files
  )

  depends_on = [module.base_repo]
}

# Project repository files module
module "project_repository_files" {
  source = "./modules/repository_files"
  for_each = {
    for repo in var.repositories : repo.name => repo
  }

  repository = each.key
  branch     = module.project_repos[each.key].default_branch
  files = concat(
    local.standard_files,
    local.repo_specific_prompt_files[each.key], # Each repo gets its own prompt file
    local.copilot_files,
    try(each.value.extra_files, [])
  )

  depends_on = [module.project_repos]
}
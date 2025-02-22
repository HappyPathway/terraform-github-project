# Repositories data source
# Base repository locals
locals {
  base_repository = merge({
    name                     = var.project_name
    description              = "Base repository for ${var.project_name} project"
    topics                   = ["project-base"]
    visibility               = "private"
    has_issues               = true
    has_wiki                 = true
    has_projects             = true
    enable_branch_protection = true
    create_codeowners        = true
    force_name               = true
  }, { for k, v in var.base_repository : k => v if k != "managed_extra_files" })
}

# File configuration locals
locals {
  # Standard repository files
  standard_files = [
    {
      content = templatefile("${path.module}/templates/README.md", {
        project_name = var.project_name
        description  = try(var.base_repository.description, "")
      })
      name = "README.md"
    },
    {
      content = templatefile("${path.module}/templates/CODEOWNERS", {
        codeowners = var.project_owners
      })
      name = ".github/CODEOWNERS"
    },
    {
      content = file("${path.module}/templates/pull_request_template.md")
      name    = ".github/pull_request_template.md"
    }
  ]

  # Project prompt files
  project_prompt_files = [
    {
      content = var.project_prompt
      name    = ".github/prompts/${var.project_name}.prompt.md"
    }
  ]

  # VS Code workspace configuration
  workspace_config_files = [
    {
      name = "${var.project_name}.code-workspace"
      content = jsonencode({
        folders = concat(
          [{ name = var.project_name, path = "." }],
          [for repo in var.repositories : {
            name = repo.name
            path = "../${repo.name}"
          }]
        )
        settings = try(local.effective_vscode.settings, {})
        extensions = {
          recommendations = distinct(concat(
            try(var.vs_code_workspace.extensions.recommended, []),
            try(var.vs_code_workspace.extensions.required, []),
            ["github.copilot", "github.copilot-chat"]
          ))
        }
        tasks = try(var.vs_code_workspace.tasks, [])
        launch = {
          version = "0.2.0"
          configurations = try(var.vs_code_workspace.launch_configurations, [])
        }
      })
    }
  ]

  # Combine all files into a single list
  all_repository_files = concat(
    local.standard_files,
    local.project_prompt_files,
    local.workspace_config_files
  )
}

# Repository files module
module "repository_files" {
  source = "./modules/repository_files"

  repository = var.project_name
  branch     = "main"
  files      = local.all_repository_files

  depends_on = [
    module.base_repo,
    module.project_repos
  ]
}

# Security module
module "security" {
  source = "./modules/security"

  repositories              = var.repositories
  enable_security_scanning  = true
  security_frameworks       = []
  container_security_config = {}

  depends_on = [
    module.base_repo,
    module.project_repos
  ]
}

# Development module
module "development" {
  source = "./modules/development"

  repositories         = var.repositories
  testing_requirements = try(var.development_config.testing_requirements, {})
  ci_cd_config         = try(var.development_config.ci_cd_config, {})

  depends_on = [
    module.base_repo,
    module.project_repos
  ]
}

# Infrastructure module
module "infrastructure" {
  source = "./modules/infrastructure"

  repositories = var.repositories
  iac_config   = try(var.infrastructure_config.iac_config, {})

  depends_on = [
    module.base_repo,
    module.project_repos
  ]
}

# Quality module
module "quality" {
  source = "./modules/quality"

  repositories   = var.repositories
  quality_config = try(var.quality_config, {})

  depends_on = [
    module.base_repo,
    module.project_repos
  ]
}

# Copilot module
module "copilot" {
  source               = "./modules/copilot"
  project_name         = var.project_name
  repositories         = var.repositories
  copilot_instructions = var.copilot_instructions
  enforce_prs          = var.enforce_prs
  github_pro_enabled   = false # As per user instructions
}
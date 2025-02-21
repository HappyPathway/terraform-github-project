# Repositories data source
data "github_repository" "existing_repos" {
  for_each  = { for repo in var.repositories : repo.name => repo if try(repo.create_repo, true) == false }
  full_name = "${coalesce(each.value.repo_org, var.repo_org)}/${each.key}"
}

# Base repository locals
locals {
  base_repository = merge({
    name                     = var.project_name # Ensure name is always set
    description              = "Base repository for ${var.project_name} project"
    topics                   = ["project-base"]
    visibility               = "private"
    has_issues               = true
    has_wiki                 = true
    has_projects             = true
    enable_branch_protection = true
    create_codeowners        = true
    force_name               = true # Ensure consistent naming without date suffix
    create_repo              = true
    branch_protection = {
      enforce_admins = true
      required_linear_history = true
      require_conversation_resolution = true
      required_status_checks = []
      allow_force_pushes = false
      allow_deletions = false
    }
    managed_extra_files = concat([
      {
        path    = ".github/prompts/${var.project_name}.prompt.md"
        content = var.project_prompt
      }
    ], var.base_repository.managed_extra_files != null ? var.base_repository.managed_extra_files : [])
  }, { for k, v in var.base_repository : k => v if k != "managed_extra_files" })
}

locals {
  managed_files = {
    "CODEOWNERS" = {
      content = templatefile("${path.module}/templates/CODEOWNERS", {
        codeowners = var.project_owners
      })
      description = "CODEOWNERS file defining code review requirements"
    }
  }

  workspace_config_files = var.vs_code_workspace != null ? {
    "${var.project_name}.code-workspace" = {
      content = jsonencode({
        folders = concat(
          [{ name = var.project_name, path = "." }],
          [for repo in var.repositories : {
            name = repo.name
            path = "../${repo.name}"
          }]
        )
        settings = try(var.vs_code_workspace.settings, {})
        extensions = {
          recommendations = distinct(concat(
            try(var.vs_code_workspace.extensions.recommended, []),
            try(var.vs_code_workspace.extensions.required, []),
            ["github.copilot", "github.copilot-chat"]
          ))
        }
        tasks = try(var.vs_code_workspace.tasks, [])
      })
      description = "VS Code workspace configuration"
    }
  } : {}
}

locals {
  copilot_instructions = {
    for file in fileset("${path.module}/docs", "copilot*.md") : 
    ".github/${file}" => file("${path.module}/docs/${file}")
  }

  repository_prompts = var.project_prompt != null ? {
    ".github/prompts/repo-setup.prompt.md" = var.project_prompt
  } : null
}

module "copilot" {
  source = "./modules/copilot"

  project_name = var.project_name
  repositories = var.repositories
  copilot_instructions = var.copilot_instructions
  enforce_prs = var.enforce_prs
  github_pro_enabled = var.github_pro_enabled
}

# Create Copilot and repository prompt files
module "repository_files" {
  for_each = module.copilot.repository_files
  source   = "./modules/repository_files"

  repository = each.key
  branch     = try(var.repositories[index(var.repositories.*.name, each.key)].github_default_branch, "main")
  files = merge(
    {
      for path, file in local.managed_files : path => file
    },
    local.workspace_config_files,
    {
      for path, content in local.copilot_instructions : path => {
        content     = content
        description = "GitHub Copilot setup instructions"
      }
    },
    // Fix the repository prompt handling
    local.repository_prompts != null ? {
      for path, content in local.repository_prompts : path => {
        content     = content
        description = "Repository prompt"
      }
    } : {}
  )

  depends_on = [
    module.base_repo,
    module.project_repos
  ]
}

module "security" {
  source = "./modules/security"

  repositories = var.repositories
  enable_security_scanning = try(var.security_config.enable_security_scanning, true)
  security_frameworks = try(var.security_config.security_frameworks, [])
  container_security_config = try(var.security_config.container_security_config, {})
  depends_on = [
    module.base_repo,
    module.project_repos
  ]
}

module "development" {
  source = "./modules/development"

  repositories = var.repositories
  testing_requirements = try(var.development_config.testing_requirements, {})
  ci_cd_config = try(var.development_config.ci_cd_config, {})
  depends_on = [
    module.base_repo,
    module.project_repos
  ]
}

module "infrastructure" {
  source = "./modules/infrastructure"

  repositories = var.repositories
  iac_config = try(var.infrastructure_config.iac_config, {})
  depends_on = [
    module.base_repo,
    module.project_repos
  ]
}

module "quality" {
  source = "./modules/quality"

  repositories = var.repositories
  quality_config = var.quality_config
  depends_on = [
    module.base_repo,
    module.project_repos
  ]
}

locals {
  # Aggregate configurations for use in templates and files
  effective_config = {
    security       = module.security.security_configuration
    development    = module.development.development_config
    infrastructure = module.infrastructure.infrastructure_config
    quality        = module.quality.code_quality_config
  }
  
  generated_copilot_instructions = module.copilot.generated_instructions
}
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
      enforce_admins                  = true
      required_linear_history         = true
      require_conversation_resolution = true
      required_approving_review_count = 1
      dismiss_stale_reviews           = true
      require_code_owner_reviews      = true
    }
    managed_extra_files = concat([
      {
        path    = ".github/prompts/${var.project_name}.prompt.md"
        content = var.project_prompt
      },
      {
        path    = ".github/copilot-instructions.md"
        content = coalesce(var.copilot_instructions, local.generated_copilot_instructions)
      },
      {
        path = ".vscode/extensions.json"
        content = jsonencode({
          recommendations = local.recommended_extensions
        })
      },
      {
        path = ".vscode/settings.json"
        content = jsonencode({
          "editor.formatOnSave" : true,
          "editor.rulers" : [80, 120],
          "[terraform]" : {
            "editor.defaultFormatter" : "hashicorp.terraform",
            "editor.formatOnSave" : true,
            "editor.formatOnSaveMode" : "file"
          },
          "files.associations" : {
            "*.tfvars" : "terraform",
            "*.tftest.hcl" : "terraform"
          }
        })
      }
    ], var.base_repository.managed_extra_files != null ? var.base_repository.managed_extra_files : [])
  }, { for k, v in var.base_repository : k => v if k != "managed_extra_files" })
}

module "copilot" {
  source = "./modules/copilot"

  project_name = var.project_name
  repositories = var.repositories
  copilot_instructions = var.copilot_instructions
  enforce_prs = var.enforce_prs
  github_pro_enabled = var.github_pro_enabled
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
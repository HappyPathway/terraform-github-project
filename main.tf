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

# Development environment module
module "development_environment" {
  source = "./modules/development_environment"

  project_name          = var.project_name
  vs_code_workspace     = try(var.vs_code_workspace, {})
  development_container = try(var.development_container, null)
  setup_dev_container   = try(var.setup_dev_container, false)
  repositories          = var.repositories
  workspace_files       = try(var.workspace_files, [])
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
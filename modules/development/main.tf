module "standards" {
  source = "./modules/standards"

  repositories         = var.repositories
  testing_requirements = var.testing_requirements
}

module "deployment" {
  source = "./modules/deployment"

  repositories = var.repositories
  ci_cd_config = var.ci_cd_config
}

locals {
  development_config = {
    standards  = module.standards.development_standards
    deployment = module.deployment.deployment_config
  }

  testing_requirements = {
    required           = try(var.testing_requirements.required, true)
    coverage_threshold = try(var.testing_requirements.coverage_threshold, 80)
    frameworks         = try(var.testing_requirements.frameworks, [])
  }

  code_quality_config = {
    linting_required       = true
    type_safety            = true
    documentation_required = true
  }

  ci_cd_config = {
    tools           = try(var.ci_cd_config.ci_cd_tools, ["github-actions"])
    required_checks = try(var.ci_cd_config.required_status_checks, [])
  }

  deployment_environments = distinct(flatten([
    for repo in var.repositories :
    try(repo.environments, [])
  ]))
}
locals {
  detected_languages = distinct(flatten([
    for repo in var.repositories : try(repo.github_repo_topics, [])
    if can(regex("^(python|javascript|typescript|go|java|ruby|php|c#|rust|kotlin|swift)$", repo.github_repo_topics[0]))
  ]))
  detected_frameworks = distinct(flatten([
    for repo in var.repositories : try(repo.github_repo_topics, [])
    if can(regex("^(react|angular|vue|django|flask|spring|rails|laravel)$", repo.github_repo_topics[0]))
  ]))
  development_config = {
    standards  = module.standards.development_standards
    deployment = module.deployment.deployment_config
  }
  standards_config  = try(module.standards.standards_config, {})
  deployment_config = try(module.deployment.deployment_config, {})
}
locals {
  deployment_strategies = distinct(flatten([
    for repo in var.repositories :
    [for topic in coalesce(repo.github_repo_topics, []) :
     topic if can(regex("^(blue-green|canary|rolling|a-b-testing)", topic))]
  ]))

  uses_gitops = anytrue([
    for repo in var.repositories :
    contains(coalesce(repo.github_repo_topics, []), "gitops") ||
    contains(coalesce(repo.github_repo_topics, []), "argocd") ||
    contains(coalesce(repo.github_repo_topics, []), "flux")
  ])

  feature_flags = anytrue([
    for repo in var.repositories :
    contains(coalesce(repo.github_repo_topics, []), "feature-flags") ||
    contains(coalesce(repo.github_repo_topics, []), "feature-toggles")
  ])

  ci_cd_tools = coalesce(var.ci_cd_config.ci_cd_tools, distinct(flatten([
    for repo in var.repositories :
    [for topic in coalesce(repo.github_repo_topics, []) :
     topic if can(regex("^(github-actions|jenkins|gitlab-ci|circle-ci)", topic))]
  ])))

  deployment_config = {
    strategies = local.deployment_strategies
    uses_gitops = local.uses_gitops
    feature_flags = local.feature_flags
    ci_cd_tools = local.ci_cd_tools
    required_status_checks = var.ci_cd_config.required_status_checks
  }
}
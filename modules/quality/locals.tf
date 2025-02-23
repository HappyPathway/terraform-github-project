locals {
  detected_linting_tools = distinct(flatten([
    for repo in var.repositories : try(repo.github_repo_topics, [])
    if can(regex("^(eslint|pylint|golint|rubocop|checkstyle)$", repo.github_repo_topics[0]))
  ]))
  detected_formatting_tools = distinct(flatten([
    for repo in var.repositories : try(repo.github_repo_topics, [])
    if can(regex("^(prettier|black|gofmt|rubocop|ktlint)$", repo.github_repo_topics[0]))
  ]))
  detected_documentation_tools = distinct(flatten([
    for repo in var.repositories : try(repo.github_repo_topics, [])
    if can(regex("^(jsdoc|sphinx|godoc|yard|javadoc)$", repo.github_repo_topics[0]))
  ]))
  has_type_checking = anytrue([
    for repo in var.repositories :
    contains(coalesce(repo.github_repo_topics, []), "typescript") ||
    contains(coalesce(repo.github_repo_topics, []), "mypy") ||
    contains(coalesce(repo.github_repo_topics, []), "flow")
  ])
  code_quality_config = {
    linting_required       = try(var.quality_config.linting_required, false)
    type_safety            = try(var.quality_config.type_safety, false)
    documentation_required = try(var.quality_config.documentation_required, false)
    has_type_checking      = local.has_type_checking
    linting_tools          = local.detected_linting_tools
    formatting_tools       = local.detected_formatting_tools
    documentation_tools    = local.detected_documentation_tools
  }
}
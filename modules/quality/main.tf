locals {
  linting_tools = coalesce(var.quality_config.linting_tools, distinct(flatten([
    for repo in var.repositories :
    [for topic in coalesce(repo.github_repo_topics, []) :
    topic if can(regex("^(eslint|flake8|rubocop|golangci-lint|pylint)", topic))]
  ])))

  formatting_tools = coalesce(var.quality_config.formatting_tools, distinct(flatten([
    for repo in var.repositories :
    [for topic in coalesce(repo.github_repo_topics, []) :
    topic if can(regex("^(prettier|black|gofmt|rustfmt)", topic))]
  ])))

  documentation_tools = coalesce(var.quality_config.documentation_tools, distinct(flatten([
    for repo in var.repositories :
    [for topic in coalesce(repo.github_repo_topics, []) :
    topic if can(regex("^(sphinx|jsdoc|godoc|javadoc|pdoc)", topic))]
  ])))

  has_type_checking = anytrue([
    for repo in var.repositories :
    contains(coalesce(repo.github_repo_topics, []), "typescript") ||
    contains(coalesce(repo.github_repo_topics, []), "mypy") ||
    contains(coalesce(repo.github_repo_topics, []), "flow")
  ])

  code_quality_config = {
    linting_required       = var.quality_config.linting_required
    type_safety            = var.quality_config.type_safety
    documentation_required = var.quality_config.documentation_required
    has_type_checking      = local.has_type_checking
    linting_tools          = local.linting_tools
    formatting_tools       = local.formatting_tools
    documentation_tools    = local.documentation_tools
  }
}
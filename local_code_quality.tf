locals {
  code_quality = {
    linting_required = anytrue([
      for repo in var.repositories :
      contains(coalesce(try(repo.required_status_checks.contexts, []), []), "lint") ||
      contains(coalesce(repo.github_repo_topics, []), "eslint") ||
      contains(coalesce(repo.github_repo_topics, []), "prettier")
    ]),
    formatting_tools = distinct(flatten([
      for repo in var.repositories : [
        for topic in coalesce(repo.github_repo_topics, []) :
        lower(topic) if contains(["prettier", "black", "gofmt", "rustfmt"], lower(topic))
      ]
    ]))
    type_safety = anytrue([
      for repo in var.repositories :
      contains(coalesce(repo.github_repo_topics, []), "typescript") ||
      contains(coalesce(repo.github_repo_topics, []), "flow") ||
      contains(coalesce(repo.github_repo_topics, []), "mypy")
    ])
    documentation_required = anytrue([
      for repo in var.repositories :
      repo.github_has_wiki == true ||
      contains(coalesce(repo.github_repo_topics, []), "documentation")
    ])
  }
}
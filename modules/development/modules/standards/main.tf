locals {
  languages = distinct(flatten([
    for repo in var.repositories :
    [for topic in coalesce(repo.github_repo_topics, []) :
    topic if can(regex("^(python|javascript|typescript|java|go|rust|cpp|csharp)", topic))]
  ]))

  frameworks = distinct(flatten([
    for repo in var.repositories :
    [for topic in coalesce(repo.github_repo_topics, []) :
    topic if can(regex("^(react|angular|vue|django|flask|fastapi|spring|express)", topic))]
  ]))

  testing_tools = distinct(flatten([
    for repo in var.repositories :
    [for topic in coalesce(repo.github_repo_topics, []) :
    topic if can(regex("^(jest|pytest|junit|testify|mocha|cypress)", topic))]
  ]))

  development_standards = {
    languages          = local.languages
    frameworks         = local.frameworks
    testing_required   = var.testing_requirements.required
    testing_tools      = local.testing_tools
    coverage_threshold = var.testing_requirements.coverage_threshold
  }
}
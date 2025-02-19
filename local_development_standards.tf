locals {
  development_standards = {
    languages = distinct(flatten([
      for repo in var.repositories : [
        for topic in coalesce(repo.github_repo_topics, []) :
        lower(topic) if contains(["typescript", "javascript", "python", "go", "java", "ruby", "php"], lower(topic))
      ]
    ]))
    frameworks = distinct(flatten([
      for repo in var.repositories : [
        for topic in coalesce(repo.github_repo_topics, []) :
        lower(topic) if contains(["react", "vue", "angular", "express", "django", "flask", "spring"], lower(topic))
      ]
    ]))
    testing_required = anytrue([
      for repo in var.repositories :
      contains(coalesce(try(repo.required_status_checks.contexts, []), []), "test") ||
      contains(coalesce(repo.github_repo_topics, []), "testing")
    ])
    ci_tool = coalesce(
      contains(flatten([for repo in var.repositories : try(repo.required_status_checks.contexts, [])]), "github-actions") ? "GitHub Actions" :
      contains(flatten([for repo in var.repositories : try(repo.required_status_checks.contexts, [])]), "jenkins") ? "Jenkins" :
      contains(flatten([for repo in var.repositories : try(repo.required_status_checks.contexts, [])]), "travis") ? "Travis CI" :
      "Not specified"
    )
  }
}
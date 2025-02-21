locals {
  module_patterns = {
    is_module = anytrue([
      for repo in var.repositories :
      contains(coalesce(repo.github_repo_topics, []), "terraform-module") ||
      contains(coalesce(repo.github_repo_topics, []), "terraform-modules")
    ])
    module_types = distinct(flatten([
      for repo in var.repositories : [
        for topic in coalesce(repo.github_repo_topics, []) :
        lower(topic) if contains([
          "infrastructure-module",
          "application-module",
          "platform-module",
          "composite-module"
        ], lower(topic))
      ]
    ]))
    testing_frameworks = distinct(flatten([
      for repo in var.repositories : [
        for topic in coalesce(repo.github_repo_topics, []) :
        lower(topic) if contains([
          "terratest",
          "kitchen-terraform",
          "terraform-compliance",
          "checkov"
        ], lower(topic))
      ]
    ]))
    documentation_tools = distinct(flatten([
      for repo in var.repositories : [
        for topic in coalesce(repo.github_repo_topics, []) :
        lower(topic) if contains([
          "terraform-docs",
          "mkdocs",
          "docusaurus"
        ], lower(topic))
      ]
    ]))
  }
}
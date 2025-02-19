locals {
  infrastructure_patterns = {
    iac_tools = distinct(flatten([
      for repo in var.repositories : [
        for topic in coalesce(repo.github_repo_topics, []) :
        lower(topic) if contains(["terraform", "cloudformation", "ansible", "puppet", "kubernetes", "helm"], lower(topic))
      ]
    ]))
    cloud_providers = distinct(flatten([
      for repo in var.repositories : [
        for topic in coalesce(repo.github_repo_topics, []) :
        lower(topic) if contains(["aws", "azure", "gcp", "digitalocean", "oracle-cloud"], lower(topic))
      ]
    ]))
    has_terraform = anytrue([
      for repo in var.repositories :
      contains(coalesce(repo.github_repo_topics, []), "terraform") ||
      contains(coalesce(try(repo.required_status_checks.contexts, []), []), "terraform")
    ])
    has_kubernetes = anytrue([
      for repo in var.repositories :
      contains(coalesce(repo.github_repo_topics, []), "kubernetes") ||
      contains(coalesce(repo.github_repo_topics, []), "helm")
    ])
    uses_modules = anytrue([
      for repo in var.repositories :
      contains(coalesce(repo.github_repo_topics, []), "terraform-module")
    ])
    deployment_environment = anytrue([
      for repo in var.repositories :
      contains(coalesce(repo.github_repo_topics, []), "production") ||
      contains(coalesce(repo.github_repo_topics, []), "staging") ||
      contains(coalesce(repo.github_repo_topics, []), "development")
    ])
  }
}
locals {
  deployment_patterns = {
    strategies = distinct(flatten([
      for repo in var.repositories : [
        for topic in coalesce(repo.github_repo_topics, []) :
        lower(topic) if contains(["blue-green", "canary", "rolling-update", "gitops"], lower(topic))
      ]
    ]))
    ci_cd_tools = distinct(flatten([
      for repo in var.repositories : [
        for topic in coalesce(repo.github_repo_topics, []) :
        lower(topic) if contains(["github-actions", "jenkins", "gitlab-ci", "argocd", "flux"], lower(topic))
      ]
    ]))
    uses_gitops = anytrue([
      for repo in var.repositories :
      contains(coalesce(repo.github_repo_topics, []), "gitops") ||
      contains(coalesce(repo.github_repo_topics, []), "flux") ||
      contains(coalesce(repo.github_repo_topics, []), "argocd")
    ])
    feature_flags = anytrue([
      for repo in var.repositories :
      contains(coalesce(repo.github_repo_topics, []), "feature-flags") ||
      contains(coalesce(repo.github_repo_topics, []), "feature-toggles")
    ])
  }
}
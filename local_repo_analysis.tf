locals {
  # Analyze security features across all repositories
  security_enabled = anytrue([
    for repo in var.repositories :
    coalesce(repo.vulnerability_alerts, false)
  ])

  repository_urls = [
    for repo in var.repositories :
    "https://github.com/${var.repo_org}/${repo.name}"
  ]

  repository_names = [
    for repo in var.repositories :
    repo.name
  ]

  # Repository configuration analysis
  repo_config = {
    # Branch cleanup settings
    branch_cleanup = var.archive_on_destroy

    # PR review requirements
    pr_requirements = {
      min_reviewers  = 1
      codeowners     = true
      dismiss_stale  = true
      enforce_admins = true
    }

    # Repository visibility and settings
    repo_settings = {
      private_repos      = true
      archive_on_destroy = var.archive_on_destroy
      secrets_exist      = false
    }

    # Repository features
    features = {
      has_projects = true
      has_wiki     = true
      has_issues   = false
    }

    # Template repository usage
    templates = {
      uses_templates   = false
      is_template_repo = false
    }

    # Access control
    access_control = {
      has_collaborators = false
      has_pr_bypassers  = false
      org_teams_used    = false
    }
  }
}
locals {
  repo_analysis = {
    merge_strategies = distinct(flatten([
      for repo in var.repositories : [
        repo.github_allow_merge_commit == true ? "merge commits" : "",
        repo.github_allow_squash_merge == true ? "squash merging" : "",
        repo.github_allow_rebase_merge == true ? "rebase merging" : ""
      ]
    ]))
    branch_cleanup       = alltrue([for repo in var.repositories : coalesce(repo.github_delete_branch_on_merge, true)])
    review_requirements = {
      required         = var.enforce_prs
      min_reviewers   = min([for repo in var.repositories : coalesce(repo.github_required_approving_review_count, 1)]...)
      codeowners      = alltrue([for repo in var.repositories : coalesce(repo.github_require_code_owner_reviews, true)])
      dismiss_stale   = alltrue([for repo in var.repositories : coalesce(repo.github_dismiss_stale_reviews, true)])
      enforce_admins  = alltrue([for repo in var.repositories : coalesce(repo.github_enforce_admins_branch_protection, true)])
    }
    security = {
      private_repos   = alltrue([for repo in var.repositories : coalesce(repo.github_is_private, true)])
      vuln_alerts    = anytrue([for repo in var.repositories : coalesce(repo.vulnerability_alerts, false)])
      secrets_exist  = length(flatten([for repo in var.repositories : coalesce(repo.secrets, [])])) > 0
      scanning       = local.security_scanning
    }
    features = {
      has_projects = alltrue([for repo in var.repositories : coalesce(repo.github_has_projects, true)])
      has_wiki     = alltrue([for repo in var.repositories : coalesce(repo.github_has_wiki, true)])
      has_issues   = alltrue([for repo in var.repositories : coalesce(repo.github_has_issues, false)])
    }
    branch_protection = {
      status_checks = distinct(flatten([
        for repo in var.repositories : 
        try(repo.required_status_checks.contexts, [])
      ])),
      strict_updates = anytrue([
        for repo in var.repositories :
        try(repo.required_status_checks.strict, false)
      ])
    }
    templating = {
      uses_templates = anytrue([
        for repo in var.repositories :
        repo.template_repo != null
      ])
      is_template = anytrue([
        for repo in var.repositories :
        repo.is_template == true
      ])
      template_sources = distinct(compact([
        for repo in var.repositories :
        try(repo.template_repo_org, null)
      ]))
    }
    collaboration = {
      has_collaborators = anytrue([
        for repo in var.repositories :
        length(coalesce(repo.collaborators, {})) > 0
      ])
      pr_bypass_allowed = anytrue([
        for repo in var.repositories :
        length(coalesce(repo.pull_request_bypassers, [])) > 0
      ])
      team_access = distinct(flatten([
        for repo in var.repositories :
        coalesce(repo.github_org_teams, [])
      ]))
    }
  }
}
locals {
  repo_analysis = {
    merge_strategies = length(var.repositories) > 0 ? distinct(flatten([
      for repo in var.repositories : [
        repo.github_allow_merge_commit == true ? "merge commits" : "",
        repo.github_allow_squash_merge == true ? "squash merging" : "",
        repo.github_allow_rebase_merge == true ? "rebase merging" : ""
      ]
    ])) : []
    branch_cleanup = length(var.repositories) > 0 ? alltrue([for repo in var.repositories : coalesce(repo.github_delete_branch_on_merge, true)]) : true
    review_requirements = {
      required       = var.enforce_prs
      min_reviewers  = length(var.repositories) > 0 ? min([for repo in var.repositories : coalesce(repo.github_required_approving_review_count, 1)]...) : 1
      codeowners     = length(var.repositories) > 0 ? alltrue([for repo in var.repositories : coalesce(repo.github_require_code_owner_reviews, true)]) : true
      dismiss_stale  = length(var.repositories) > 0 ? alltrue([for repo in var.repositories : coalesce(repo.github_dismiss_stale_reviews, true)]) : true
      enforce_admins = length(var.repositories) > 0 ? alltrue([for repo in var.repositories : coalesce(repo.github_enforce_admins_branch_protection, true)]) : true
    }
    security = {
      private_repos = alltrue([for repo in var.repositories : coalesce(repo.github_is_private, true)])
      vuln_alerts   = anytrue([for repo in var.repositories : coalesce(repo.vulnerability_alerts, false)])
      secrets_exist = length(flatten([for repo in var.repositories : coalesce(repo.secrets, [])])) > 0
      scanning      = local.security_scanning
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
      has_collaborators = length(var.repositories) > 0 ? anytrue([
        for repo in var.repositories :
        length(coalesce(repo.collaborators, {})) > 0
      ]) : false
      pr_bypass_allowed = length(var.repositories) > 0 ? anytrue([
        for repo in var.repositories :
        length(coalesce(repo.pull_request_bypassers, [])) > 0
      ]) : false
      team_access = length(var.repositories) > 0 ? distinct(flatten([
        for repo in var.repositories :
        coalesce(repo.github_org_teams, [])
      ])) : []
    }
  }

  # Default values for empty repository list
  default_stats = {
    min_reviewers = 1
    max_reviewers = 1
    avg_reviewers = 1
  }

  # Repository analysis with safe handling of empty lists
  repository_analysis = {
    has_repos = length(var.repositories) > 0
    review_stats = length(var.repositories) == 0 ? local.default_stats : {
      min_reviewers = min([for repo in var.repositories : try(coalesce(repo.github_required_approving_review_count, 1), 1)]...)
      max_reviewers = max([for repo in var.repositories : try(coalesce(repo.github_required_approving_review_count, 1), 1)]...)
      avg_reviewers = sum([for repo in var.repositories : try(coalesce(repo.github_required_approving_review_count, 1), 1)]) / length(var.repositories)
    }
    visibility_stats = {
      public_count  = length([for repo in coalesce(var.repositories, []) : repo if try(repo.visibility, "public") == "public"])
      private_count = length([for repo in coalesce(var.repositories, []) : repo if try(repo.visibility, "public") == "private"])
    }
  }
}
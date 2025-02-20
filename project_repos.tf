# Project repositories configuration
locals {
  project_repositories = { for repo in var.repositories : repo.name => repo }
  default_prompt_content = "No specific guidelines provided"
}

module "project_repos" {
  source   = "HappyPathway/repo/github"
  for_each = { for name, repo in local.project_repositories : name => repo if try(repo.create_repo, true) }

  # Basic repository settings
  name       = each.key
  repo_org   = coalesce(each.value.repo_org, var.repo_org)
  force_name = try(each.value.force_name, false)

  # Repository configuration
  create_repo             = true
  enforce_prs             = try(each.value.enable_branch_protection, true)
  github_repo_description = try(each.value.description, "Repository for ${var.project_name} project")
  github_repo_topics      = try(each.value.topics, [])
  github_is_private       = try(each.value.visibility, "private") == "private"
  github_has_issues       = try(each.value.has_issues, true)
  github_has_wiki         = try(each.value.has_wiki, true)
  github_has_projects     = try(each.value.has_projects, true)
  github_has_discussions  = try(each.value.has_discussions, false)
  github_has_downloads    = try(each.value.has_downloads, false)

  # Git settings
  github_default_branch         = try(each.value.default_branch, var.default_branch)
  github_allow_merge_commit     = try(each.value.allow_merge_commit, true)
  github_allow_squash_merge     = try(each.value.allow_squash_merge, true)
  github_allow_rebase_merge     = try(each.value.allow_rebase_merge, true)
  github_allow_auto_merge       = try(each.value.allow_auto_merge, false)
  github_delete_branch_on_merge = try(each.value.delete_branch_on_merge, true)
  github_allow_update_branch    = try(each.value.allow_update_branch, true)

  # File management
  extra_files = try(each.value.extra_files, [])
  managed_extra_files = concat(
    coalesce(each.value.managed_extra_files, []),
    [
      {
        path    = "${each.key}-${var.project_name}-prompt.md"
        content = coalesce(
          try(each.value.prompt, null),
          try(each.value.description, null),
          "${local.default_prompt_content} for ${each.key}"
        )
      }
    ]
  )

  # Teams and access control
  admin_teams      = try(each.value.admin_teams, [])
  github_org_teams = try(each.value.github_org_teams, {})

  # Additional settings
  archived              = try(each.value.archived, false)
  archive_on_destroy    = try(each.value.archive_on_destroy, true)
  vulnerability_alerts  = try(each.value.vulnerability_alerts, true)
  gitignore_template    = try(each.value.gitignore_template, null)
  license_template      = try(each.value.license_template, null)
  homepage_url          = try(each.value.homepage_url, null)
  security_and_analysis = try(each.value.security_and_analysis, null)

  # Template configuration if specified
  template_repo     = try(each.value.template.repository, null)
  template_repo_org = try(each.value.template.owner, null)

  depends_on = [module.base_repo]
}

# Branch protection for project repositories
resource "github_branch_protection" "project_repos" {
  for_each = {
    for name, repo in local.project_repositories : name => repo
    if try(repo.create_repo, true) && try(repo.enable_branch_protection, true)
  }

  repository_id = module.project_repos[each.key].github_repo.node_id
  pattern       = try(each.value.default_branch, var.default_branch)

  enforce_admins          = try(each.value.branch_protection.enforce_admins, true)
  required_linear_history = try(each.value.branch_protection.required_linear_history, true)
  allows_force_pushes     = try(each.value.branch_protection.allow_force_pushes, false)
  allows_deletions        = try(each.value.branch_protection.allow_deletions, false)
  require_signed_commits  = try(each.value.require_signed_commits, false)

  required_pull_request_reviews {
    dismiss_stale_reviews           = try(each.value.branch_protection.dismiss_stale_reviews, true)
    require_code_owner_reviews      = try(each.value.branch_protection.require_code_owner_reviews, true)
    required_approving_review_count = try(each.value.branch_protection.required_approving_review_count, 1)
  }

  dynamic "required_status_checks" {
    for_each = try(each.value.branch_protection.required_status_checks, null) != null ? ["true"] : []
    content {
      strict   = try(each.value.branch_protection.required_status_checks.strict, true)
      contexts = try(each.value.branch_protection.required_status_checks.contexts, [])
    }
  }

  depends_on = [module.project_repos]
}
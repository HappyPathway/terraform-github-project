# Project repositories configuration
locals {
  project_repositories   = { for repo in var.repositories : repo.name => repo }
  default_prompt_content = "No specific guidelines provided"
}

module "project_repos" {
  source = "HappyPathway/repo/github"
  for_each = { 
    for name, repo in local.processed_repos : name => repo 
    if repo.create_repo 
  }

  # Basic repository settings
  name       = each.key
  repo_org   = coalesce(each.value.repo_org, var.repo_org)
  force_name = each.value.force_name

  # Repository configuration 
  create_repo             = true
  enforce_prs             = each.value.visibility == "public" || each.value.force_branch_protection
  github_repo_description = coalesce(each.value.description, "Repository for ${var.project_name} project")
  github_repo_topics      = each.value.topics
  github_is_private       = each.value.visibility == "private"

  # Feature flags
  github_has_issues      = each.value.has_issues
  github_has_wiki        = each.value.has_wiki
  github_has_projects    = each.value.has_projects
  github_has_discussions = each.value.has_discussions
  github_has_downloads   = each.value.has_downloads
  github_default_branch  = each.value.default_branch

  # File management
  extra_files = each.value.extra_files
  managed_extra_files = each.value.visibility == "private" ? concat(
    coalesce(try(each.value.managed_extra_files, []), []),
    [{
      path = ".github/FREE_TIER_LIMITATIONS.md"
      content = templatefile("${path.module}/templates/github_free_limitations.md.tpl", {
        repo_name = each.key
        limitations = [
          "Branch protection rules are only available for public repositories",
          "Advanced security features are limited",
          "Private repository features require GitHub Pro or higher"
        ]
      })
    }]
  ) : coalesce(try(each.value.managed_extra_files, []), [])

  # Teams and access control
  admin_teams = each.value.admin_teams
  github_org_teams = each.value.github_org_teams

  # Branch protection settings - only applied for public repos or when forced
  github_enforce_admins_branch_protection = (each.value.visibility == "public" || each.value.force_branch_protection) ? try(each.value.branch_protection.enforce_admins, true) : false
  github_dismiss_stale_reviews = (each.value.visibility == "public" || each.value.force_branch_protection) ? try(each.value.branch_protection.dismiss_stale_reviews, true) : false
  github_require_code_owner_reviews = (each.value.visibility == "public" || each.value.force_branch_protection) ? try(each.value.branch_protection.require_code_owner_reviews, true) : false
  github_required_approving_review_count = (each.value.visibility == "public" || each.value.force_branch_protection) ? try(each.value.branch_protection.required_approving_review_count, 1) : 0

  # Other settings passed through
  template_repo = try(each.value.template.repository, null)
  template_repo_org = try(each.value.template.owner, null)
}

# Branch protection for project repositories
resource "github_branch_protection" "project_repos" {
  for_each = {
    for name, repo in local.processed_repos : name => repo
    if repo.create_repo && 
       repo.enable_branch_protection && 
       (repo.visibility == "public" || repo.force_branch_protection)
  }

  repository_id = module.project_repos[each.key].github_repo.node_id
  pattern       = each.value.default_branch

  enforce_admins          = try(each.value.branch_protection.enforce_admins, true)
  required_linear_history = try(each.value.branch_protection.required_linear_history, true)
  allows_force_pushes     = try(each.value.branch_protection.allow_force_pushes, false)
  allows_deletions        = try(each.value.branch_protection.allow_deletions, false)
  require_signed_commits  = each.value.require_signed_commits

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
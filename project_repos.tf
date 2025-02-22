# Handle project prompt and repository specific prompts
locals {
  project_repositories = { for repo in var.repositories : repo.name => repo }
  base_prompt_content  = trimspace(var.project_prompt)

  # Only enable branch protection for public repos or when GitHub Pro is enabled
  branch_protection_enabled = {
    for name, repo in local.project_repositories : name => (
      try(repo.create_repo, true) &&
      try(repo.enable_branch_protection, true) &&
      (try(repo.visibility, "private") == "public" || var.github_pro_enabled)
    )
  }

  # Repository-specific prompts with proper inheritance
  repository_prompts = {
    for name, repo in local.project_repositories : name => {
      content = trimspace(coalesce(
        try(repo.prompt, null),
        try(repo.description, null),
        local.base_prompt_content
      ))
      name = "${var.project_name}.prompt.md"
    }
  }
}

module "project_repos" {
  source   = "HappyPathway/repo/github"
  for_each = { for name, repo in local.project_repositories : name => repo if try(repo.create_repo, true) }

  # Basic repository settings
  name       = each.key
  repo_org   = coalesce(each.value.repo_org, var.repo_org)
  force_name = true
  # Repository configuration - inherit from base repo if not specified
  create_repo             = true
  enforce_prs             = local.branch_protection_enabled[each.key]
  github_repo_description = try(each.value.description, "Repository for the ${var.project_name} project in ${module.base_repo.github_repo.name}")
  github_repo_topics      = try(each.value.topics, module.base_repo.github_repo.topics)
  github_is_private       = try(each.value.visibility, module.base_repo.github_repo.visibility) == "private"
  github_has_issues       = try(each.value.has_issues, module.base_repo.github_repo.has_issues)
  github_has_wiki         = coalesce(try(each.value.has_wiki, null), try(var.base_repository.has_wiki, false))
  github_has_projects     = try(each.value.has_projects, module.base_repo.github_repo.has_projects)
  github_has_discussions  = try(each.value.has_discussions, module.base_repo.github_repo.has_discussions)
  github_has_downloads    = try(each.value.has_downloads, module.base_repo.github_repo.has_downloads)

  # Git settings - inherit from base repo
  github_default_branch         = try(each.value.default_branch, var.repositories[index(var.repositories.*.name, each.key)].github_default_branch)
  github_allow_merge_commit     = try(each.value.allow_merge_commit, module.base_repo.github_repo.allow_merge_commit)
  github_allow_squash_merge     = try(each.value.allow_squash_merge, module.base_repo.github_repo.allow_squash_merge)
  github_allow_rebase_merge     = try(each.value.allow_rebase_merge, module.base_repo.github_repo.allow_rebase_merge)
  github_allow_auto_merge       = try(each.value.allow_auto_merge, module.base_repo.github_repo.allow_auto_merge)
  github_delete_branch_on_merge = try(each.value.delete_branch_on_merge, module.base_repo.github_repo.delete_branch_on_merge)
  github_allow_update_branch    = try(each.value.allow_update_branch, module.base_repo.github_repo.allow_update_branch)

  # File management with prompts
  extra_files = try(each.value.extra_files, [])
  managed_extra_files = concat(
    coalesce(try(each.value.managed_extra_files, []), []),
    [
      {
        path    = ".github/prompts/${local.repository_prompts[each.key].name}"
        content = local.repository_prompts[each.key].content
      }
    ]
  )

  # Teams and access control - inherit from base repo config
  admin_teams      = try(each.value.admin_teams, local.base_repo_config.admin_teams)
  github_org_teams = try(each.value.github_org_teams, local.base_repo_config.github_org_teams)

  # Additional settings - inherit from base repo
  archived              = try(each.value.archived, module.base_repo.github_repo.archived)
  archive_on_destroy    = var.archive_on_destroy
  vulnerability_alerts  = try(each.value.vulnerability_alerts, module.base_repo.github_repo.vulnerability_alerts)
  gitignore_template    = try(each.value.gitignore_template, module.base_repo.github_repo.gitignore_template)
  license_template      = try(each.value.license_template, module.base_repo.github_repo.license_template)
  homepage_url          = try(each.value.homepage_url, module.base_repo.github_repo.homepage_url)
  security_and_analysis = try(each.value.security_and_analysis, module.base_repo.github_repo.security_and_analysis)

  # Template configuration if specified
  template_repo     = try(each.value.template.repository, null)
  template_repo_org = try(each.value.template.owner, null)

  depends_on = [module.base_repo]
}

# Branch protection for project repositories
resource "github_branch_protection" "project_repos" {
  for_each = {
    for name, repo in local.project_repositories : name => repo
    if local.branch_protection_enabled[name] && var.github_pro_enabled
  }

  repository_id = module.project_repos[each.key].github_repo.node_id
  pattern       = try(each.value.default_branch, module.base_repo.github_repo.default_branch)

  enforce_admins          = try(each.value.branch_protection.enforce_admins, local.base_repo_config.branch_protection.enforce_admins)
  required_linear_history = try(each.value.branch_protection.required_linear_history, local.base_repo_config.branch_protection.required_linear_history)
  allows_force_pushes     = try(each.value.branch_protection.allow_force_pushes, local.base_repo_config.branch_protection.allow_force_pushes)
  allows_deletions        = try(each.value.branch_protection.allow_deletions, local.base_repo_config.branch_protection.allow_deletions)
  require_signed_commits  = try(each.value.require_signed_commits, local.base_repo_config.require_signed_commits)

  required_pull_request_reviews {
    dismiss_stale_reviews           = try(each.value.branch_protection.dismiss_stale_reviews, local.base_repo_config.branch_protection.dismiss_stale_reviews)
    require_code_owner_reviews      = try(each.value.branch_protection.require_code_owner_reviews, local.base_repo_config.branch_protection.require_code_owner_reviews)
    required_approving_review_count = try(each.value.branch_protection.required_approving_review_count, local.base_repo_config.branch_protection.required_approving_review_count)
  }

  dynamic "required_status_checks" {
    for_each = try(each.value.branch_protection.required_status_checks, local.base_repo_config.branch_protection.required_status_checks) != null ? ["true"] : []
    content {
      strict   = try(each.value.branch_protection.required_status_checks.strict, local.base_repo_config.branch_protection.required_status_checks.strict)
      contexts = try(each.value.branch_protection.required_status_checks.contexts, local.base_repo_config.branch_protection.required_status_checks.contexts)
    }
  }

  depends_on = [module.project_repos]
}
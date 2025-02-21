# Create base repository without branch protection or files initially
module "base_repo" {
  source = "HappyPathway/repo/github"

  # Ensure required parameters are set
  name       = var.project_name
  repo_org   = var.repo_org
  force_name = true # Prevent date suffix

  # Basic repository settings
  create_repo             = true
  enforce_prs             = false # Disable branch protection initially
  github_repo_description = local.base_repository.description
  github_repo_topics      = local.base_repository.topics
  github_is_private       = local.base_repository.visibility == "private"
  github_has_issues       = local.base_repository.has_issues
  github_has_wiki         = local.base_repository.has_wiki
  github_has_projects     = local.base_repository.has_projects
  github_has_discussions  = local.base_repository.has_discussions
  github_has_downloads    = local.base_repository.has_downloads

  # Git settings
  github_default_branch         = local.base_repository.default_branch
  github_allow_merge_commit     = local.base_repository.allow_merge_commit
  github_allow_squash_merge     = local.base_repository.allow_squash_merge
  github_allow_rebase_merge     = local.base_repository.allow_rebase_merge
  github_allow_auto_merge       = local.base_repository.allow_auto_merge
  github_delete_branch_on_merge = local.base_repository.delete_branch_on_merge
  github_allow_update_branch    = local.base_repository.allow_update_branch

  # Don't manage files in the module
  extra_files         = []
  managed_extra_files = []

  # Teams and access control
  admin_teams      = local.base_repository.admin_teams
  github_org_teams = local.base_repository.github_org_teams

  # Additional settings
  archived              = local.base_repository.archived
  archive_on_destroy    = local.base_repository.archive_on_destroy
  vulnerability_alerts  = local.base_repository.vulnerability_alerts
  gitignore_template    = local.base_repository.gitignore_template
  license_template      = local.base_repository.license_template
  homepage_url          = local.base_repository.homepage_url
  security_and_analysis = local.base_repository.security_and_analysis

  # Source template if specified
  template_repo     = try(local.base_repository.template.repository, null)
  template_repo_org = try(local.base_repository.template.owner, null)
}

# Create repository files
resource "github_repository_file" "base_repo_files" {
  for_each = {
    for file in local.base_repository.managed_extra_files :
    file.path => file
  }

  repository          = module.base_repo.github_repo.name
  branch              = module.base_repo.default_branch
  file                = each.value.path
  content             = each.value.content
  commit_message      = "Add ${each.value.path}"
  overwrite_on_create = true

  depends_on = [module.base_repo]
}

# Add CODEOWNERS file
resource "github_repository_file" "base_repo_codeowners" {
  count = local.base_repository.create_codeowners ? 1 : 0

  repository = module.base_repo.github_repo.name
  branch     = module.base_repo.default_branch
  file       = "CODEOWNERS"
  content = templatefile("${path.module}/templates/CODEOWNERS", {
    codeowners = concat(
      try(local.base_repository.codeowners, []),
      formatlist("* @%s", try(local.base_repository.admin_teams, []))
    )
  })
  commit_message      = "Add CODEOWNERS file"
  overwrite_on_create = true

  depends_on = [module.base_repo]
}

# Add branch protection after files are created
resource "github_branch_protection" "base_repo" {
  # Only create branch protection if repo is public or explicitly enabled
  count = (local.base_repository.visibility == "public" || try(local.base_repository.force_branch_protection, false)) && local.base_repository.enable_branch_protection ? 1 : 0

  repository_id = module.base_repo.github_repo.node_id
  pattern       = module.base_repo.default_branch

  enforce_admins          = local.base_repository.branch_protection.enforce_admins
  required_linear_history = local.base_repository.branch_protection.required_linear_history
  allows_force_pushes     = try(local.base_repository.branch_protection.allow_force_pushes, false)
  allows_deletions        = try(local.base_repository.branch_protection.allow_deletions, false)
  require_signed_commits  = try(local.base_repository.require_signed_commits, false)

  required_pull_request_reviews {
    dismiss_stale_reviews           = local.base_repository.branch_protection.dismiss_stale_reviews
    require_code_owner_reviews      = local.base_repository.branch_protection.require_code_owner_reviews
    required_approving_review_count = local.base_repository.branch_protection.required_approving_review_count
  }

  dynamic "required_status_checks" {
    for_each = try(local.base_repository.branch_protection.required_status_checks, null) != null ? ["true"] : []
    content {
      strict   = try(local.base_repository.branch_protection.required_status_checks.strict, true)
      contexts = try(local.base_repository.branch_protection.required_status_checks.contexts, [])
    }
  }

  depends_on = [
    github_repository_file.base_repo_files,
    github_repository_file.base_repo_codeowners
  ]
}

# Create initialization files in the base repository
resource "github_repository_file" "base_files" {
  for_each = local.repo_files

  repository     = module.base_repo.github_repo.name
  branch         = var.default_branch
  file           = each.key
  content        = each.value.content
  commit_message = "Add ${each.value.description}"
}
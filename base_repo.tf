# Create base repository configuration
locals {
  base_repo_config = merge(var.base_repository, {
    # ... existing defaults ...
    
    # Only enable branch protection for public repos or when GitHub Pro is enabled
    enable_branch_protection = (
      try(var.base_repository.enable_branch_protection, true) && 
      (try(var.base_repository.visibility, "private") == "public" || var.github_pro_enabled)
    )
  })
}

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
  github_repo_description = local.base_repo_config.description
  github_repo_topics      = local.base_repo_config.topics
  github_is_private       = local.base_repo_config.visibility == "private"
  github_has_issues       = local.base_repo_config.has_issues
  github_has_wiki         = local.base_repo_config.has_wiki
  github_has_projects     = local.base_repo_config.has_projects
  github_has_discussions  = local.base_repo_config.has_discussions
  github_has_downloads    = local.base_repo_config.has_downloads

  # Git settings
  github_default_branch         = local.base_repo_config.default_branch
  github_allow_merge_commit     = local.base_repo_config.allow_merge_commit
  github_allow_squash_merge     = local.base_repo_config.allow_squash_merge
  github_allow_rebase_merge     = local.base_repo_config.allow_rebase_merge
  github_allow_auto_merge       = local.base_repo_config.allow_auto_merge
  github_delete_branch_on_merge = local.base_repo_config.delete_branch_on_merge
  github_allow_update_branch    = local.base_repo_config.allow_update_branch

  # Don't manage files in the module
  extra_files         = []
  managed_extra_files = []

  # Teams and access control
  admin_teams      = local.base_repo_config.admin_teams
  github_org_teams = local.base_repo_config.github_org_teams

  # Additional settings
  archived              = local.base_repo_config.archived
  archive_on_destroy    = local.base_repo_config.archive_on_destroy
  vulnerability_alerts  = local.base_repo_config.vulnerability_alerts
  gitignore_template    = local.base_repo_config.gitignore_template
  license_template      = local.base_repo_config.license_template
  homepage_url          = local.base_repo_config.homepage_url
  security_and_analysis = local.base_repo_config.security_and_analysis

  # Source template if specified
  template_repo     = try(local.base_repo_config.template.repository, null)
  template_repo_org = try(local.base_repo_config.template.owner, null)
}

# Create repository files
resource "github_repository_file" "base_repo_files" {
  for_each = local.base_repo_config.managed_extra_files == null ? {} : {
    for file in local.base_repo_config.managed_extra_files :
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
  count = local.base_repo_config.create_codeowners ? 1 : 0

  repository = module.base_repo.github_repo.name
  branch     = module.base_repo.default_branch
  file       = "CODEOWNERS"
  content = templatefile("${path.module}/templates/CODEOWNERS", {
    codeowners = concat(
      try(local.base_repo_config.codeowners, []),
      formatlist("* @%s", try(local.base_repo_config.admin_teams, []))
    )
  })
  commit_message      = "Add CODEOWNERS file"
  overwrite_on_create = true

  depends_on = [module.base_repo]
}

# Add branch protection after files are created
resource "github_branch_protection" "base_repo" {
  count = try(local.base_repo_config.enable_branch_protection, true) ? 1 : 0

  repository_id = module.base_repo.github_repo.node_id
  pattern       = module.base_repo.default_branch

  enforce_admins          = try(local.base_repo_config.branch_protection.enforce_admins, true)
  required_linear_history = try(local.base_repo_config.branch_protection.required_linear_history, true)
  allows_force_pushes     = try(local.base_repo_config.branch_protection.allow_force_pushes, false)
  allows_deletions        = try(local.base_repo_config.branch_protection.allow_deletions, false)
  require_signed_commits  = try(local.base_repo_config.require_signed_commits, false)

  required_pull_request_reviews {
    dismiss_stale_reviews           = try(local.base_repo_config.branch_protection.dismiss_stale_reviews, true)
    require_code_owner_reviews      = try(local.base_repo_config.branch_protection.require_code_owner_reviews, true)
    required_approving_review_count = try(local.base_repo_config.branch_protection.required_approving_review_count, 1)
  }

  dynamic "required_status_checks" {
    for_each = try(local.base_repo_config.branch_protection.required_status_checks, null) != null ? ["true"] : []
    content {
      strict   = try(local.base_repo_config.branch_protection.required_status_checks.strict, true)
      contexts = try(local.base_repo_config.branch_protection.required_status_checks.contexts, [])
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
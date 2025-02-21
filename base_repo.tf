locals {
  # Normalize base repository configuration
  base_repository = {
    name = var.project_name
    description = try(var.base_repository.description, "Base repository for ${var.project_name}")
    visibility = try(var.base_repository.visibility, "public")  # Changed default to public
    force_branch_protection = try(var.base_repository.force_branch_protection, false)
    enable_branch_protection = try(var.base_repository.enable_branch_protection, true)
    topics = try(var.base_repository.topics, [])
    github_org_teams = try(var.base_repository.github_org_teams, [])
    admin_teams = try(var.base_repository.admin_teams, [])
    extra_files = try(var.base_repository.extra_files, [])
    managed_extra_files = try(var.base_repository.managed_extra_files, [])
    create_repo = try(var.base_repository.create_repo, true)
    create_codeowners = try(var.base_repository.create_codeowners, true)
  }
}

module "base_repo" {
  source = "HappyPathway/repo/github"

  name = local.base_repository.name
  repo_org = var.repo_org

  # Repository configuration
  create_repo = local.base_repository.create_repo
  enforce_prs = local.base_repository.visibility == "public" || local.base_repository.force_branch_protection
  github_is_private = local.base_repository.visibility == "private"
  github_repo_description = local.base_repository.description
  github_repo_topics = local.base_repository.topics

  # File management
  extra_files = local.base_repository.extra_files
  managed_extra_files = concat(
    [],  # Start with empty list to ensure we always have a valid list
    coalesce(try(local.base_repository.managed_extra_files, []), []),
    local.base_repository.visibility == "private" ? [{
      path = ".github/FREE_TIER_LIMITATIONS.md"
      content = file("${path.module}/templates/github_free_limitations.md.tpl")
    }] : []
  )

  # Teams and access control
  admin_teams = local.base_repository.admin_teams
  github_org_teams = local.base_repository.github_org_teams

  # Branch protection settings - only applied for public repos or when forced
  github_enforce_admins_branch_protection = (local.base_repository.visibility == "public" || local.base_repository.force_branch_protection) ? try(local.base_repository.branch_protection.enforce_admins, true) : false
  github_dismiss_stale_reviews = (local.base_repository.visibility == "public" || local.base_repository.force_branch_protection) ? try(local.base_repository.branch_protection.dismiss_stale_reviews, true) : false
  github_require_code_owner_reviews = (local.base_repository.visibility == "public" || local.base_repository.force_branch_protection) ? try(local.base_repository.branch_protection.require_code_owner_reviews, true) : false
  github_required_approving_review_count = (local.base_repository.visibility == "public" || local.base_repository.force_branch_protection) ? try(local.base_repository.branch_protection.required_approving_review_count, 1) : 0

  # Other settings passed through
  template_repo = try(var.base_repository.template.repository, null)
  template_repo_org = try(var.base_repository.template.owner, null)
}

# Create repository files
resource "github_repository_file" "base_repo_files" {
  for_each = {
    for file in coalesce(local.base_repository.managed_extra_files, []) :
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

# Add CODEOWNERS file if enabled
resource "github_repository_file" "base_repo_codeowners" {
  count = local.base_repository.create_codeowners ? 1 : 0

  repository = module.base_repo.github_repo.name
  branch     = module.base_repo.default_branch
  file       = "CODEOWNERS"
  content = templatefile("${path.module}/templates/CODEOWNERS", {
    codeowners = distinct(concat(
      try(local.base_repository.codeowners, []),
      formatlist("* @%s", try(local.base_repository.admin_teams, []))
    ))
  })
  commit_message      = "Add CODEOWNERS file"
  overwrite_on_create = true

  depends_on = [module.base_repo]
}

# Add branch protection after files are created
resource "github_branch_protection" "base_repo" {
  count = (local.base_repository.visibility == "public" || local.base_repository.force_branch_protection) && local.base_repository.enable_branch_protection ? 1 : 0

  repository_id = module.base_repo.github_repo.node_id
  pattern       = module.base_repo.default_branch

  enforce_admins          = local.base_repository.branch_protection.enforce_admins
  required_linear_history = local.base_repository.branch_protection.required_linear_history 
  allows_force_pushes     = try(local.base_repository.branch_protection.allow_force_pushes, false)
  allows_deletions        = try(local.base_repository.branch_protection.allow_deletions, false)

  required_pull_request_reviews {
    dismiss_stale_reviews = try(local.base_repository.branch_protection.dismiss_stale_reviews, true)
    require_code_owner_reviews = try(local.base_repository.branch_protection.require_code_owner_reviews, true)
    required_approving_review_count = try(local.base_repository.branch_protection.required_approving_review_count, 1)
  }

  dynamic "required_status_checks" {
    for_each = try(local.base_repository.branch_protection.required_status_checks, null) != null ? ["true"] : []
    content {
      strict   = try(local.base_repository.branch_protection.required_status_checks.strict, true)
      contexts = try(local.base_repository.branch_protection.required_status_checks.contexts, [])
    }
  }

  depends_on = [
    module.base_repo,
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
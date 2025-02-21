locals {
  # Default repository settings for GitHub Free tier compatibility
  repo_defaults = {
    visibility = "public"  # Default to public for GitHub Free tier
    enable_branch_protection = false  # Default to false, enable explicitly
    force_branch_protection = false
    branch_protection = {
      enforce_admins = true
      required_linear_history = true
      require_conversation_resolution = true
      required_approving_review_count = 1
      dismiss_stale_reviews = true
      require_code_owner_reviews = true
      allow_force_pushes = false
      allow_deletions = false
    }
    repo_org = null
    force_name = false
    managed_extra_files = []
    github_org_teams = []
    admin_teams = []
    extra_files = []
    require_signed_commits = false
    create_repo = true
    has_issues = false
    has_wiki = true
    has_projects = true
    has_discussions = false
    has_downloads = false
    default_branch = "main"
  }

  # Process repositories with defaults and GitHub Free tier rules
  processed_repos = {
    for repo in var.repositories :
    repo.name => merge(
      local.repo_defaults,
      {
        name = repo.name
        visibility = coalesce(try(repo.visibility, null), local.repo_defaults.visibility)
        enable_branch_protection = coalesce(
          try(repo.enable_branch_protection, null),
          repo.visibility == "public" # Only enable by default for public repos
        )
        topics = try(repo.github_repo_topics, [])
        description = try(repo.github_repo_description, null)
        force_branch_protection = try(repo.force_branch_protection, false)
        branch_protection = try(repo.branch_protection, local.repo_defaults.branch_protection)
        github_org_teams = try(repo.github_org_teams, [])
        admin_teams = try(repo.admin_teams, [])
        extra_files = try(repo.extra_files, [])
        managed_extra_files = try(repo.managed_extra_files, [])
        has_issues = try(repo.has_issues, local.repo_defaults.has_issues)
        has_wiki = try(repo.has_wiki, local.repo_defaults.has_wiki)
        has_projects = try(repo.has_projects, local.repo_defaults.has_projects)
        has_discussions = try(repo.has_discussions, local.repo_defaults.has_discussions)
        has_downloads = try(repo.has_downloads, local.repo_defaults.has_downloads)
        default_branch = try(repo.default_branch, local.repo_defaults.default_branch)
      }
    )
  }

  # Base repository configuration
  base_repo_config = {
    visibility = coalesce(try(var.base_repository.visibility, null), local.repo_defaults.visibility)
    enable_branch_protection = coalesce(
      try(var.base_repository.enable_branch_protection, null),
      var.base_repository.visibility == "public"
    )
    force_branch_protection = try(var.base_repository.force_branch_protection, false)
  }

  # Free tier validation checks
  free_tier_validation = {
    private_repos_with_protection = concat(
      # Check project repositories
      [
        for name, repo in local.processed_repos :
        name if repo.visibility == "private" && repo.enable_branch_protection && !repo.force_branch_protection
      ],
      # Check base repository
      local.base_repo_config.visibility == "private" && 
      local.base_repo_config.enable_branch_protection && 
      !local.base_repo_config.force_branch_protection ? [var.project_name] : []
    )
  }

  # Validation results for UI feedback
  validation_results = {
    error_messages = compact([
      length(local.free_tier_validation.private_repos_with_protection) > 0 ?
      "Branch protection cannot be enabled for private repositories in GitHub Free tier: ${join(", ", local.free_tier_validation.private_repos_with_protection)}" : ""
    ])
    warning_messages = compact([
      "Some repositories are private and will have limited features in GitHub Free tier."
    ])
  }

  # Project validation results
  project_validation = {
    has_warnings = length(local.free_tier_validation.private_repos_with_protection) > 0
    warnings = local.validation_results.error_messages
  }

  initialization_template_vars = {
    project_name  = var.project_name
    repo_org      = var.repo_org
    base_repo     = try(var.repositories[0].name, "")
    repositories  = keys(local.processed_repos)
    custom_script = try(var.initialization_script.content, "")
    has_warnings = length(local.free_tier_validation.private_repos_with_protection) > 0
    warnings = local.validation_results.error_messages
  }

  # Generate workspace file content
  workspace_content = templatefile(
    "${path.module}/templates/workspace.json.tpl",
    {
      folders                = local.workspace_folders
      recommended_extensions = local.recommended_extensions
    }
  )

  # Generate initialization script content
  init_script_content = templatefile(
    "${path.module}/templates/init.sh.tpl",
    local.initialization_template_vars
  )

  # Files to be created in the base repository
  repo_files = {
    "${var.project_name}.code-workspace" = {
      content     = local.workspace_content
      description = "VS Code workspace configuration"
    }
    "init.sh" = {
      content     = local.init_script_content
      description = "Project initialization script"
    }
  }
}
// Add data source for existing repositories
data "github_repository" "existing_repos" {
  for_each  = { for repo in var.repositories : repo.name => repo if try(repo.create_repo, true) == false }
  full_name = "${coalesce(each.value.repo_org, var.repo_org)}/${each.key}"
}

locals {
  base_repository = merge({
    name = var.project_name  # Ensure name is always set
    description = "Base repository for ${var.project_name} project"
    topics = ["project-base"]
    visibility = "private"
    has_issues = true
    has_wiki = true
    has_projects = true
    enable_branch_protection = true
    create_codeowners = true
    force_name = true  # Ensure consistent naming without date suffix
    create_repo = true
    branch_protection = {
      enforce_admins = true
      required_linear_history = true
      require_conversation_resolution = true
      required_approving_review_count = 1
      dismiss_stale_reviews = true
      require_code_owner_reviews = true
    }
    managed_extra_files = [
      {
        path    = ".github/prompts/project.prompt.md"
        content = var.project_prompt
      },
      {
        path    = ".github/copilot-instructions.md"
        content = coalesce(var.copilot_instructions, local.generated_copilot_instructions)
      },
      {
        path    = ".vscode/extensions.json"
        content = jsonencode({
          recommendations = [
            "hashicorp.terraform",
            "github.vscode-github-actions",
            "github.copilot",
            "github.copilot-chat"
          ]
        })
      },
      {
        path    = ".vscode/settings.json"
        content = jsonencode({
          "editor.formatOnSave": true,
          "editor.rulers": [80, 120],
          "[terraform]": {
            "editor.defaultFormatter": "hashicorp.terraform",
            "editor.formatOnSave": true,
            "editor.formatOnSaveMode": "file"
          },
          "files.associations": {
            "*.tfvars": "terraform",
            "*.tftest.hcl": "terraform"
          }
        })
      }
    ]
  }, var.base_repository)
}

# Create base repository without branch protection or files initially
module "base_repo" {
  source = "HappyPathway/repo/github"
  
  # Ensure required parameters are set
  name = var.project_name
  repo_org = var.repo_org
  force_name = true  # Prevent date suffix
  
  # Basic repository settings
  create_repo = true
  enforce_prs = false  # Disable branch protection initially
  github_repo_description = local.base_repository.description
  github_repo_topics = local.base_repository.topics
  github_is_private = local.base_repository.visibility == "private"
  github_has_issues = local.base_repository.has_issues
  github_has_wiki = local.base_repository.has_wiki
  github_has_projects = local.base_repository.has_projects
  github_has_discussions = local.base_repository.has_discussions
  github_has_downloads = local.base_repository.has_downloads
  
  # Git settings
  github_default_branch = local.base_repository.default_branch
  github_allow_merge_commit = local.base_repository.allow_merge_commit
  github_allow_squash_merge = local.base_repository.allow_squash_merge
  github_allow_rebase_merge = local.base_repository.allow_rebase_merge
  github_allow_auto_merge = local.base_repository.allow_auto_merge
  github_delete_branch_on_merge = local.base_repository.delete_branch_on_merge
  github_allow_update_branch = local.base_repository.allow_update_branch

  # Don't manage files in the module
  extra_files = []
  managed_extra_files = []

  # Teams and access control
  admin_teams = local.base_repository.admin_teams
  github_org_teams = local.base_repository.github_org_teams

  # Additional settings
  archived = local.base_repository.archived
  archive_on_destroy = local.base_repository.archive_on_destroy
  vulnerability_alerts = local.base_repository.vulnerability_alerts
  gitignore_template = local.base_repository.gitignore_template
  license_template = local.base_repository.license_template
  homepage_url = local.base_repository.homepage_url
  security_and_analysis = local.base_repository.security_and_analysis

  # Source template if specified
  template_repo = try(local.base_repository.template.repository, null)
  template_repo_org = try(local.base_repository.template.owner, null)
}

// Create repository files
resource "github_repository_file" "base_repo_files" {
  for_each = {
    for file in local.base_repository.managed_extra_files :
    file.path => file
  }

  repository          = module.base_repo.github_repo.name
  branch             = module.base_repo.default_branch
  file               = each.value.path
  content            = each.value.content
  commit_message     = "Add ${each.value.path}"
  overwrite_on_create = true

  depends_on = [module.base_repo]
}

// Add CODEOWNERS file
resource "github_repository_file" "base_repo_codeowners" {
  count = local.base_repository.create_codeowners ? 1 : 0

  repository          = module.base_repo.github_repo.name
  branch             = module.base_repo.default_branch
  file               = "CODEOWNERS"
  content            = templatefile("${path.module}/templates/CODEOWNERS", {
    codeowners = concat(
      try(local.base_repository.codeowners, []),
      formatlist("* @%s", try(local.base_repository.admin_teams, []))
    )
  })
  commit_message     = "Add CODEOWNERS file"
  overwrite_on_create = true

  depends_on = [module.base_repo]
}

// Add branch protection after files are created
resource "github_branch_protection" "base_repo" {
  count = local.base_repository.enable_branch_protection ? 1 : 0

  repository_id = module.base_repo.github_repo.node_id
  pattern       = module.base_repo.default_branch

  enforce_admins         = local.base_repository.branch_protection.enforce_admins
  required_linear_history = local.base_repository.branch_protection.required_linear_history
  allows_force_pushes     = try(local.base_repository.branch_protection.allow_force_pushes, false)
  allows_deletions        = try(local.base_repository.branch_protection.allow_deletions, false)
  require_signed_commits = try(local.base_repository.require_signed_commits, false)
  
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

module "project_repos" {
  source   = "HappyPathway/repo/github"
  for_each = { for idx, repo in var.repositories : repo.name => repo }

  name                                   = each.value.name
  repo_org                              = var.repo_org
  create_repo                           = try(each.value.create_repo, true)
  github_repo_description               = each.value.github_repo_description
  github_repo_topics                    = each.value.github_repo_topics
  github_push_restrictions              = each.value.github_push_restrictions
  github_is_private                     = each.value.github_is_private
  github_auto_init                      = each.value.github_auto_init
  github_allow_merge_commit             = each.value.github_allow_merge_commit
  github_allow_squash_merge             = each.value.github_allow_squash_merge
  github_allow_rebase_merge             = each.value.github_allow_rebase_merge
  github_delete_branch_on_merge         = each.value.github_delete_branch_on_merge
  github_has_projects                   = each.value.github_has_projects
  github_has_issues                     = each.value.github_has_issues
  github_has_wiki                       = each.value.github_has_wiki
  github_default_branch                 = each.value.github_default_branch
  github_required_approving_review_count = each.value.github_required_approving_review_count
  github_require_code_owner_reviews     = each.value.github_require_code_owner_reviews
  github_dismiss_stale_reviews          = each.value.github_dismiss_stale_reviews
  github_enforce_admins_branch_protection = each.value.github_enforce_admins_branch_protection
  additional_codeowners                 = each.value.additional_codeowners
  prefix                                = each.value.prefix
  force_name                            = each.value.force_name
  github_org_teams                      = each.value.github_org_teams
  template_repo_org                     = each.value.template_repo_org
  template_repo                         = each.value.template_repo
  is_template                           = each.value.is_template
  admin_teams                           = each.value.admin_teams
  required_status_checks                = each.value.required_status_checks
  archived                              = each.value.archived
  secrets                               = each.value.secrets
  vars                                  = each.value.vars
  extra_files                           = each.value.extra_files
  managed_extra_files = concat(
    coalesce(each.value.managed_extra_files, []),
    [{
      path    = ".github/prompts/repo-setup.prompt.md"
      content = each.value.prompt
    }]
  )
  pull_request_bypassers                = each.value.pull_request_bypassers
  create_codeowners                     = each.value.create_codeowners
  enforce_prs                           = try(each.value.enforce_prs, var.enforce_prs)
  collaborators                         = each.value.collaborators
  archive_on_destroy                    = each.value.archive_on_destroy
  vulnerability_alerts                  = each.value.vulnerability_alerts
  gitignore_template                    = each.value.gitignore_template
  homepage_url                          = each.value.homepage_url
  security_and_analysis                 = each.value.security_and_analysis

  depends_on = [module.base_repo]
}
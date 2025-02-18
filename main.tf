locals {
  workspace_folders = concat(
    [{
      name = var.project_name
      path = "."
    }],
    [for repo in var.repositories : {
      name = repo.name
      path = "../${repo.name}"
    }],
    coalesce(var.workspace_files, [])
  )

  master_repo = {
    name                    = var.project_name
    github_repo_description = "Master repository for ${var.project_name} project"
    github_repo_topics      = ["project-master"]
    managed_extra_files = concat([
      {
        path    = ".github/prompts/project-setup.prompt.md"
        content = var.project_prompt
      },
      {
        path = "${var.project_name}.code-workspace"
        content = jsonencode({
          folders = local.workspace_folders
        })
      }
    ], coalesce(try(var.repositories[0].managed_extra_files, []), []))
  }

  master_repo_config = merge(
    try(var.repositories[0], {}),
    local.master_repo
  )
}

module "master_repo" {
  source = "../terraform-github-repo"

  name                                    = local.master_repo_config.name
  repo_org                                = try(local.master_repo_config.repo_org, null)
  github_repo_description                 = local.master_repo_config.github_repo_description
  github_repo_topics                      = local.master_repo_config.github_repo_topics
  github_push_restrictions                = try(local.master_repo_config.github_push_restrictions, [])
  github_is_private                       = try(local.master_repo_config.github_is_private, true)
  github_auto_init                        = try(local.master_repo_config.github_auto_init, true)
  github_allow_merge_commit               = try(local.master_repo_config.github_allow_merge_commit, false)
  github_allow_squash_merge               = try(local.master_repo_config.github_allow_squash_merge, true)
  github_allow_rebase_merge               = try(local.master_repo_config.github_allow_rebase_merge, false)
  github_delete_branch_on_merge           = try(local.master_repo_config.github_delete_branch_on_merge, true)
  github_has_projects                     = try(local.master_repo_config.github_has_projects, true)
  github_has_issues                       = try(local.master_repo_config.github_has_issues, false)
  github_has_wiki                         = try(local.master_repo_config.github_has_wiki, true)
  github_default_branch                   = try(local.master_repo_config.github_default_branch, "main")
  github_required_approving_review_count  = try(local.master_repo_config.github_required_approving_review_count, 1)
  github_require_code_owner_reviews       = try(local.master_repo_config.github_require_code_owner_reviews, true)
  github_dismiss_stale_reviews            = try(local.master_repo_config.github_dismiss_stale_reviews, true)
  github_enforce_admins_branch_protection = try(local.master_repo_config.github_enforce_admins_branch_protection, true)
  additional_codeowners                   = try(local.master_repo_config.additional_codeowners, [])
  prefix                                  = try(local.master_repo_config.prefix, null)
  force_name                              = try(local.master_repo_config.force_name, false)
  github_org_teams                        = try(local.master_repo_config.github_org_teams, null)
  template_repo_org                       = try(local.master_repo_config.template_repo_org, null)
  template_repo                           = try(local.master_repo_config.template_repo, null)
  is_template                             = try(local.master_repo_config.is_template, false)
  admin_teams                             = try(local.master_repo_config.admin_teams, [])
  required_status_checks                  = try(local.master_repo_config.required_status_checks, null)
  archived                                = try(local.master_repo_config.archived, false)
  secrets                                 = try(local.master_repo_config.secrets, [])
  vars                                    = try(local.master_repo_config.vars, [])
  extra_files                             = try(local.master_repo_config.extra_files, [])
  managed_extra_files                     = local.master_repo_config.managed_extra_files
  pull_request_bypassers                  = try(local.master_repo_config.pull_request_bypassers, [])
  create_codeowners                       = try(local.master_repo_config.create_codeowners, true)
  enforce_prs                             = try(local.master_repo_config.enforce_prs, true)
  collaborators                           = try(local.master_repo_config.collaborators, {})
  archive_on_destroy                      = try(local.master_repo_config.archive_on_destroy, true)
  vulnerability_alerts                    = try(local.master_repo_config.vulnerability_alerts, false)
  gitignore_template                      = try(local.master_repo_config.gitignore_template, null)
  homepage_url                            = try(local.master_repo_config.homepage_url, null)
  security_and_analysis                   = try(local.master_repo_config.security_and_analysis, null)
}

module "project_repos" {
  source   = "../terraform-github-repo"
  for_each = { for idx, repo in var.repositories : repo.name => repo }

  name                                    = each.value.name
  repo_org                                = each.value.repo_org
  github_repo_description                 = each.value.github_repo_description
  github_repo_topics                      = each.value.github_repo_topics
  github_push_restrictions                = each.value.github_push_restrictions
  github_is_private                       = each.value.github_is_private
  github_auto_init                        = each.value.github_auto_init
  github_allow_merge_commit               = each.value.github_allow_merge_commit
  github_allow_squash_merge               = each.value.github_allow_squash_merge
  github_allow_rebase_merge               = each.value.github_allow_rebase_merge
  github_delete_branch_on_merge           = each.value.github_delete_branch_on_merge
  github_has_projects                     = each.value.github_has_projects
  github_has_issues                       = each.value.github_has_issues
  github_has_wiki                         = each.value.github_has_wiki
  github_default_branch                   = each.value.github_default_branch
  github_required_approving_review_count  = each.value.github_required_approving_review_count
  github_require_code_owner_reviews       = each.value.github_require_code_owner_reviews
  github_dismiss_stale_reviews            = each.value.github_dismiss_stale_reviews
  github_enforce_admins_branch_protection = each.value.github_enforce_admins_branch_protection
  additional_codeowners                   = each.value.additional_codeowners
  prefix                                  = each.value.prefix
  force_name                              = each.value.force_name
  github_org_teams                        = each.value.github_org_teams
  template_repo_org                       = each.value.template_repo_org
  template_repo                           = each.value.template_repo
  is_template                             = each.value.is_template
  admin_teams                             = each.value.admin_teams
  required_status_checks                  = each.value.required_status_checks
  archived                                = each.value.archived
  secrets                                 = each.value.secrets
  vars                                    = each.value.vars
  extra_files                             = each.value.extra_files
  managed_extra_files = concat(
    coalesce(each.value.managed_extra_files, []),
    [{
      path    = ".github/prompts/repo-setup.prompt.md"
      content = each.value.prompt
    }]
  )
  pull_request_bypassers = each.value.pull_request_bypassers
  create_codeowners      = each.value.create_codeowners
  enforce_prs            = each.value.enforce_prs
  collaborators          = each.value.collaborators
  archive_on_destroy     = each.value.archive_on_destroy
  vulnerability_alerts   = each.value.vulnerability_alerts
  gitignore_template     = each.value.gitignore_template
  homepage_url           = each.value.homepage_url
  security_and_analysis  = each.value.security_and_analysis
}
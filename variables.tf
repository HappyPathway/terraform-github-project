variable "project_name" {
  description = "Name of the project - will be used as prefix for repos and in documentation"
  type        = string
}

variable "project_prompt" {
  description = "GitHub Copilot prompt for the master repository, providing context and instructions for project-wide code generation"
  type        = string
}

variable "workspace_files" {
  description = "Additional files to include in the VS Code workspace configuration"
  type = list(object({
    name = string
    path = string
  }))
  default = []
}

variable "repositories" {
  description = "List of repository configurations for the project"
  type = list(object({
    name                                    = string
    repo_org                                = optional(string)
    prompt                                  = string # GitHub Copilot prompt for repository-specific code generation
    github_repo_description                 = optional(string)
    github_repo_topics                      = optional(list(any), [])
    github_push_restrictions                = optional(list(any), [])
    github_is_private                       = optional(bool, true)
    github_auto_init                        = optional(bool, true)
    github_allow_merge_commit               = optional(bool, false)
    github_allow_squash_merge               = optional(bool, true)
    github_allow_rebase_merge               = optional(bool, false)
    github_delete_branch_on_merge           = optional(bool, true)
    github_has_projects                     = optional(bool, true)
    github_has_issues                       = optional(bool, false)
    github_has_wiki                         = optional(bool, true)
    github_default_branch                   = optional(string, "main")
    github_required_approving_review_count  = optional(number, 1)
    github_require_code_owner_reviews       = optional(bool, true)
    github_dismiss_stale_reviews            = optional(bool, true)
    github_enforce_admins_branch_protection = optional(bool, true)
    additional_codeowners                   = optional(list(any), [])
    prefix                                  = optional(string)
    force_name                              = optional(bool, false)
    github_org_teams                        = optional(list(any))
    template_repo_org                       = optional(string)
    template_repo                           = optional(string)
    is_template                             = optional(bool, false)
    admin_teams                             = optional(list(any), [])
    required_status_checks = optional(object({
      contexts = list(string)
      strict   = optional(bool, false)
    }))
    archived = optional(bool, false)
    secrets = optional(list(object({
      name  = string
      value = string
    })), [])
    vars = optional(list(object({
      name  = string
      value = string
    })), [])
    extra_files = optional(list(object({
      path    = string
      content = string
    })), [])
    managed_extra_files = optional(list(object({
      path    = string
      content = string
    })), [])
    pull_request_bypassers = optional(list(any), [])
    create_codeowners      = optional(bool, true)
    enforce_prs            = optional(bool, true)
    collaborators          = optional(map(string), {})
    archive_on_destroy     = optional(bool, true)
    vulnerability_alerts   = optional(bool, false)
    gitignore_template     = optional(string)
    homepage_url           = optional(string)
    security_and_analysis = optional(object({
      advanced_security = optional(object({
        status = string
      }), { status = "disabled" })
      secret_scanning = optional(object({
        status = string
      }), { status = "disabled" })
      secret_scanning_push_protection = optional(object({
        status = string
      }), { status = "disabled" })
    }))
  }))
}
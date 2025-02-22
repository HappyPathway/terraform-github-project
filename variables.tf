variable "project_name" {
  description = "Name of the project. Will be used as the base repository name."
  type        = string

  validation {
    condition     = can(regex("^[a-zA-Z0-9_-]+$", var.project_name))
    error_message = "Project name must contain only alphanumeric characters, underscores, and hyphens."
  }
}

variable "repo_org" {
  description = "GitHub organization name"
  type        = string

  validation {
    condition     = can(regex("^[a-zA-Z0-9-]+$", var.repo_org))
    error_message = "Organization name must contain only alphanumeric characters and hyphens."
  }
}

variable "project_prompt" {
  description = "Content for the project's prompt file"
  type        = string

  validation {
    condition     = length(var.project_prompt) > 0
    error_message = "Project prompt cannot be empty."
  }
}

variable "copilot_instructions" {
  description = "Custom Copilot instructions. If not provided, generated instructions will be used."
  type        = string
  default     = null
}

variable "enforce_prs" {
  description = "Whether to enforce pull request reviews across all repositories"
  type        = bool
  default     = true
}

variable "repositories" {
  description = "List of project repositories to create/manage"
  type = list(object({
    name                                    = string
    repo_org                                = optional(string)
    create_repo                             = optional(bool, true)
    github_repo_description                 = optional(string)
    github_repo_topics                      = optional(list(string), [])
    github_push_restrictions                = optional(list(string), [])
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
    additional_codeowners                   = optional(list(string), [])
    prefix                                  = optional(string)
    force_name                              = optional(bool, false)
    github_org_teams                        = optional(list(any))
    template_repo_org                       = optional(string)
    template_repo                           = optional(string)
    is_template                             = optional(bool, false)
    admin_teams                             = optional(list(string), [])
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
    })))
    pull_request_bypassers = optional(list(string), [])
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
      }))
      secret_scanning = optional(object({
        status = string
      }))
      secret_scanning_push_protection = optional(object({
        status = string
      }))
    }))
    prompt = optional(string)
  }))
  default = []
}

variable "base_repository" {
  description = "Configuration for the base repository. This repository serves as the foundation for the project and contains shared configurations."
  type = object({
    # Core settings
    description     = optional(string)
    homepage_url    = optional(string)
    topics          = optional(list(string), ["project-base"])
    visibility      = optional(string, "private")
    has_issues      = optional(bool, true)
    has_wiki        = optional(bool, true)
    has_projects    = optional(bool, true)
    has_discussions = optional(bool, false)
    has_downloads   = optional(bool, false)

    # Git settings
    default_branch              = optional(string, "main")
    allow_merge_commit          = optional(bool, false)
    allow_squash_merge          = optional(bool, true)
    allow_rebase_merge          = optional(bool, false)
    allow_auto_merge            = optional(bool, false)
    delete_branch_on_merge      = optional(bool, true)
    allow_update_branch         = optional(bool, true)
    merge_commit_title          = optional(string, "MERGE_MESSAGE")
    merge_commit_message        = optional(string, "PR_TITLE")
    squash_merge_commit_title   = optional(string, "COMMIT_OR_PR_TITLE")
    squash_merge_commit_message = optional(string, "COMMIT_MESSAGES")

    # Security settings
    vulnerability_alerts = optional(bool, true)
    security_and_analysis = optional(object({
      advanced_security = optional(object({
        status = string
      }))
      secret_scanning = optional(object({
        status = string
      }))
      secret_scanning_push_protection = optional(object({
        status = string
      }))
    }))
    require_signed_commits = optional(bool, false)

    # Protection settings
    enable_branch_protection = optional(bool, false)
    enforce_prs              = optional(bool, false)
    branch_protection = optional(object({
      enforce_admins                  = optional(bool, true)
      required_linear_history         = optional(bool, true)
      allow_force_pushes              = optional(bool, false)
      allow_deletions                 = optional(bool, false)
      require_conversation_resolution = optional(bool, true)
      required_approving_review_count = optional(number, 1)
      dismiss_stale_reviews           = optional(bool, true)
      require_code_owner_reviews      = optional(bool, true)
      required_status_checks = optional(object({
        strict   = optional(bool, true)
        contexts = optional(list(string), [])
      }))
    }))
    pull_request_bypassers = optional(list(string), [])

    # File management
    gitignore_template = optional(string)
    license_template   = optional(string)
    codeowners         = optional(list(string), [])
    create_codeowners  = optional(bool, true)
    extra_files = optional(list(object({
      path    = string
      content = string
    })), [])
    managed_extra_files = optional(list(object({
      path    = string
      content = string
    })))
    allow_unsigned_files = optional(bool, false)
    commit_author        = optional(string, "Terraform")
    commit_email         = optional(string, "terraform@roknsound.com")

    # Access control
    admin_teams      = optional(list(string), [])
    push_teams       = optional(list(string), [])
    maintain_teams   = optional(list(string), [])
    pull_teams       = optional(list(string), [])
    triage_teams     = optional(list(string), [])
    collaborators    = optional(map(string), {})
    github_org_teams = optional(list(any))

    # Additional settings
    template = optional(object({
      owner      = string
      repository = string
    }))
    pages = optional(object({
      branch = string
      path   = optional(string, "/")
      cname  = optional(string)
    }))
    archived           = optional(bool, false)
    archive_on_destroy = optional(bool, true)
    create_repo        = optional(bool, true)
    prefix             = optional(string)
    force_name         = optional(bool, false)
    is_template        = optional(bool, false)
  })
  default = {}
}

variable "workspace_files" {
  description = "Additional files to include in the VS Code workspace configuration"
  type = list(object({
    name = string
    path = string
  }))
  default = []
}

variable "initialization_script" {
  description = "Optional custom initialization script to be appended to the default git clone commands"
  type = object({
    name    = string
    content = string
  })
  default = null
}

variable "environments" {
  description = "Configuration for GitHub environments in each repository"
  type = map(list(object({
    name = string
    reviewers = optional(object({
      teams = optional(list(string), [])
      users = optional(list(string), [])
    }), {})
    deployment_branch_policy = optional(object({
      protected_branches     = optional(bool, true)
      custom_branch_policies = optional(bool, false)
    }), {})
    secrets = optional(list(object({
      name  = string
      value = string
    })), [])
    vars = optional(list(object({
      name  = string
      value = string
    })), [])
  })))
  default = {}

  validation {
    condition = alltrue([
      for env_list in values(var.environments) : alltrue([
        for env in env_list : can(regex("^[a-zA-Z0-9_-]+$", env.name))
      ])
    ])
    error_message = "Environment names must contain only alphanumeric characters, underscores, and hyphens."
  }
}

variable "default_branch" {
  description = "The default branch name for all repositories"
  type        = string
  default     = "main"
}

variable "security_config" {
  description = "Configuration for security module including container, network, and compliance settings"
  type = object({
    enable_security_scanning = optional(bool, true)
    security_frameworks      = optional(list(string), [])
    container_security_config = optional(object({
      scanning_tools    = optional(list(string), [])
      runtime_security  = optional(list(string), [])
      registry_security = optional(list(string), [])
      uses_distroless   = optional(bool, false)
    }), {})
  })
  default = {}
}

variable "development_config" {
  description = "Configuration for development module including standards and deployment patterns"
  type = object({
    testing_requirements = optional(object({
      required           = optional(bool, true)
      coverage_threshold = optional(number, 80)
    }), {})
    ci_cd_config = optional(object({
      ci_cd_tools            = optional(list(string), [])
      required_status_checks = optional(list(string), [])
    }), {})
  })
  default = {}
}

variable "infrastructure_config" {
  description = "Configuration for infrastructure module including IaC and cloud providers"
  type = object({
    iac_config = optional(object({
      iac_tools           = optional(list(string), [])
      cloud_providers     = optional(list(string), [])
      documentation_tools = optional(list(string), ["terraform-docs"])
      testing_frameworks  = optional(list(string), [])
    }), {})
  })
  default = {}
}

variable "github_pro_enabled" {
  description = "Set to true if you have GitHub Pro subscription. Some features like branch protection on private repositories require GitHub Pro."
  type        = bool
  default     = false
}

variable "quality_config" {
  description = "Configuration for code quality module including linting and documentation requirements"
  type = object({
    enable_code_scanning   = optional(bool, true)
    code_quality_tools     = optional(list(string), [])
    linting_required       = optional(bool, true)
    type_safety            = optional(bool, true)
    documentation_required = optional(bool, true)
    formatting_tools       = optional(list(string), [])
    linting_tools          = optional(list(string), [])
    documentation_tools    = optional(list(string), [])
  })
  default = {}
}

variable "project_owners" {
  description = "List of GitHub usernames that are owners of the project"
  type        = list(string)
  default     = []
}

variable archive_on_destroy {
  description = "Archive repositories on destroy"
  type        = bool
  default     = true
}

variable setup_dev_container {
  description = "Set up a development container for the project"
  type        = bool
  default     = false
}
output "base_repo" {
  description = "All attributes of the master repository"
  value = {
    # Basic repository info
    name        = module.base_repo.github_repo.name
    full_name   = module.base_repo.github_repo.full_name
    description = module.base_repo.github_repo.description
    html_url    = module.base_repo.github_repo.html_url
    ssh_url     = module.base_repo.ssh_clone_url
    http_url    = module.base_repo.github_repo.http_clone_url
    git_url     = module.base_repo.github_repo.git_clone_url
    visibility  = module.base_repo.github_repo.visibility

    # Repository settings
    topics                 = module.base_repo.github_repo.topics
    has_issues             = module.base_repo.github_repo.has_issues
    has_projects           = module.base_repo.github_repo.has_projects
    has_wiki               = module.base_repo.github_repo.has_wiki
    is_template            = module.base_repo.github_repo.is_template
    allow_merge_commit     = module.base_repo.github_repo.allow_merge_commit
    allow_squash_merge     = module.base_repo.github_repo.allow_squash_merge
    allow_rebase_merge     = module.base_repo.github_repo.allow_rebase_merge
    allow_auto_merge       = module.base_repo.github_repo.allow_auto_merge
    delete_branch_on_merge = module.base_repo.github_repo.delete_branch_on_merge

    # Additional metadata
    default_branch = module.base_repo.github_repo.default_branch
    archived       = module.base_repo.github_repo.archived
    homepage_url   = module.base_repo.github_repo.homepage_url
    node_id        = module.base_repo.github_repo.node_id

    # Git details
    template = module.base_repo.github_repo.template
  }
}

output "project_repos" {
  description = "Map of all project repositories and their attributes"
  value = {
    for name, repo in module.project_repos : name => {
      # Basic repository info
      name        = repo.github_repo.name
      full_name   = repo.github_repo.full_name
      description = repo.github_repo.description
      html_url    = repo.github_repo.html_url
      ssh_url     = repo.ssh_clone_url
      http_url    = repo.github_repo.http_clone_url
      git_url     = repo.github_repo.git_clone_url
      visibility  = repo.github_repo.visibility

      # Repository settings
      topics             = repo.github_repo.topics
      has_issues         = repo.github_repo.has_issues
      has_projects       = repo.github_repo.has_projects
      has_wiki           = repo.github_repo.has_wiki
      is_template        = repo.github_repo.is_template
      allow_merge_commit = repo.github_repo.allow_merge_commit
      allow_squash_merge = repo.github_repo.allow_squash_merge
      allow_rebase_merge = repo.github_repo.allow_rebase_merge
      allow_auto_merge   = repo.github_repo.allow_auto_merge

      # Additional metadata
      default_branch = repo.github_repo.default_branch
      archived       = repo.github_repo.archived
      homepage_url   = repo.github_repo.homepage_url
      node_id        = repo.github_repo.node_id

      # Git details
      template = repo.github_repo.template
    }
  }
}

output "workspace_file_path" {
  description = "Path to the VS Code workspace file in the base repository"
  value = {
    repository = module.base_repo.github_repo.name
    path       = "${var.project_name}.code-workspace"
    html_url   = "https://github.com/${var.repo_org}/${module.base_repo.github_repo.name}/blob/${module.base_repo.default_branch}/${var.project_name}.code-workspace"
  }
}

output "copilot_files" {
  description = "Paths to the GitHub Copilot files for each repository"
  value = {
    master = {
      instructions = ".github/copilot-instructions.md"
      prompt       = try(".github/prompts/${var.project_name}.prompt.md", null)
    }
    repos = {
      for name, repo in module.project_repos : name => {
        prompt = try(".github/prompts/${name}.prompt.md", null)
      }
    }
  }
}

output "all_repos" {
  description = "Combined map of all repositories including master repo"
  value = merge(
    { (var.project_name) = module.base_repo },
    module.project_repos
  )
}

output "repository_urls" {
  description = "Map of repository names and their URLs"
  value       = local.repository_urls
}

output "security_status" {
  description = "Security configuration status for all repositories"
  value = merge(
    { (var.project_name) = {
      private = module.base_repo.github_repo.visibility == "private"
    } },
    {
      for name, repo in module.project_repos : name => {
        private = repo.github_repo.visibility == "private"
      }
    }
  )
}

output "base_repository" {
  description = "All attributes of the base repository"
  value       = module.base_repo.github_repo
}

output "repositories" {
  description = "All project repositories"
  value = {
    for name, repo in module.project_repos : name => repo.github_repo
  }
}

output "base_repository_files" {
  description = "Base repository files created in the workspace"
  value = {
    repository    = module.base_repository_files.repository
    managed_files = var.mkfiles ? module.base_repository_files.files : {}
  }
}

output "repository_names" {
  description = "Map of repository names and their details"
  value       = local.repository_names
}

output "security_configuration" {
  description = "Complete security configuration derived from repository analysis"
  value = {
    container_security = module.security.container_security_config
    network_security   = module.security.network_security_config
    compliance         = module.security.compliance_config
  }
}

output "development_configuration" {
  description = "Development standards and deployment configuration"
  value = {
    standards  = module.development.standards_config
    deployment = module.development.deployment_config
    languages  = module.development.detected_languages
    frameworks = module.development.detected_frameworks
  }
}

output "infrastructure_configuration" {
  description = "Infrastructure patterns and module configuration"
  value = {
    iac_tools       = module.infrastructure.detected_iac_tools
    cloud_providers = module.infrastructure.detected_cloud_providers
    has_kubernetes  = module.infrastructure.has_kubernetes
    module_config   = module.infrastructure.module_config
  }
}

output "quality_configuration" {
  description = "Code quality standards and tooling configuration"
  value = {
    code_quality_config = module.quality.code_quality_config
    linting_tools       = module.quality.detected_linting_tools
    formatting_tools    = module.quality.detected_formatting_tools
    documentation_tools = module.quality.detected_documentation_tools
    has_type_checking   = module.quality.has_type_checking
  }
}

output "copilot_configuration" {
  description = "GitHub Copilot configuration and detected patterns"
  value = {
    instructions    = module.copilot.copilot_instructions
    languages       = module.copilot.detected_languages
    frameworks      = module.copilot.detected_frameworks
    testing_tools   = module.copilot.detected_testing_tools
    iac_tools       = module.copilot.detected_iac_tools
    cloud_providers = module.copilot.detected_cloud_providers
    security_tools  = module.copilot.detected_security_tools
  }
}
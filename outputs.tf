output "master_repo" {
  description = "All attributes of the master repository"
  value = {
    # Basic repository info
    name        = module.master_repo.github_repo.name
    full_name   = module.master_repo.github_repo.full_name
    description = module.master_repo.github_repo.description
    html_url    = module.master_repo.github_repo.html_url
    ssh_url     = module.master_repo.ssh_clone_url
    http_url    = module.master_repo.github_repo.http_clone_url
    git_url     = module.master_repo.github_repo.git_clone_url
    visibility  = module.master_repo.github_repo.visibility
    
    # Repository settings
    topics                  = module.master_repo.github_repo.topics
    has_issues             = module.master_repo.github_repo.has_issues
    has_projects           = module.master_repo.github_repo.has_projects
    has_wiki               = module.master_repo.github_repo.has_wiki
    is_template            = module.master_repo.github_repo.is_template
    allow_merge_commit     = module.master_repo.github_repo.allow_merge_commit
    allow_squash_merge     = module.master_repo.github_repo.allow_squash_merge
    allow_rebase_merge     = module.master_repo.github_repo.allow_rebase_merge
    allow_auto_merge       = module.master_repo.github_repo.allow_auto_merge
    delete_branch_on_merge = module.master_repo.github_repo.delete_branch_on_merge
    
    # Additional metadata
    default_branch        = module.master_repo.github_repo.default_branch
    archived             = module.master_repo.github_repo.archived
    homepage_url         = module.master_repo.github_repo.homepage_url
    vulnerability_alerts = module.master_repo.github_repo.vulnerability_alerts
    node_id             = module.master_repo.github_repo.node_id
    
    # Git details
    template = module.master_repo.github_repo.template
    gitignore_template = module.master_repo.github_repo.gitignore_template
    license_template   = module.master_repo.github_repo.license_template
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
      topics                  = repo.github_repo.topics
      has_issues             = repo.github_repo.has_issues
      has_projects           = repo.github_repo.has_projects
      has_wiki               = repo.github_repo.has_wiki
      is_template            = repo.github_repo.is_template
      allow_merge_commit     = repo.github_repo.allow_merge_commit
      allow_squash_merge     = repo.github_repo.allow_squash_merge
      allow_rebase_merge     = repo.github_repo.allow_rebase_merge
      allow_auto_merge       = repo.github_repo.allow_auto_merge
      delete_branch_on_merge = repo.github_repo.delete_branch_on_merge
      
      # Additional metadata
      default_branch        = repo.github_repo.default_branch
      archived             = repo.github_repo.archived
      homepage_url         = repo.github_repo.homepage_url
      vulnerability_alerts = repo.github_repo.vulnerability_alerts
      node_id             = repo.github_repo.node_id
      
      # Git details
      template = repo.github_repo.template
      gitignore_template = repo.github_repo.gitignore_template
      license_template   = repo.github_repo.license_template
    }
  }
}

output "workspace_file_path" {
  description = "Path to the generated VS Code workspace file"
  value       = "${module.master_repo.github_repo.name}/${var.project_name}.code-workspace"
}

output "copilot_prompts" {
  description = "Paths to the GitHub Copilot prompt files for each repository"
  value = {
    master = "${module.master_repo.github_repo.name}/.github/prompts/project-setup.prompt.md"
    repos = {
      for name, repo in module.project_repos : name => "${repo.github_repo.name}/.github/prompts/repo-setup.prompt.md"
    }
  }
}

output "all_repos" {
  description = "Combined map of all repositories including master repo"
  value = merge(
    { (var.project_name) = module.master_repo },
    module.project_repos
  )
}

output "repository_urls" {
  description = "Map of repository names to their various URLs"
  value = merge(
    { (var.project_name) = {
      html_url    = module.master_repo.github_repo.html_url
      ssh_url     = module.master_repo.ssh_clone_url
      http_url    = module.master_repo.github_repo.http_clone_url
      git_url     = module.master_repo.github_repo.git_clone_url
    }},
    {
      for name, repo in module.project_repos : name => {
        html_url    = repo.github_repo.html_url
        ssh_url     = repo.ssh_clone_url
        http_url    = repo.github_repo.http_clone_url
        git_url     = repo.github_repo.git_clone_url
      }
    }
  )
}

output "security_status" {
  description = "Security configuration status for all repositories"
  value = merge(
    { (var.project_name) = {
      private              = module.master_repo.github_repo.visibility == "private"
      vulnerability_alerts = module.master_repo.github_repo.vulnerability_alerts
    }},
    {
      for name, repo in module.project_repos : name => {
        private              = repo.github_repo.visibility == "private"
        vulnerability_alerts = repo.github_repo.vulnerability_alerts
      }
    }
  )
}
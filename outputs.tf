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
      topics                 = repo.github_repo.topics
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
    repository = var.base_repository.name
    path       = "${var.project_name}.code-workspace"
    html_url   = "https://github.com/${var.repo_org}/${var.base_repository.name}/blob/${coalesce(var.base_repository.default_branch, "main")}/${var.project_name}.code-workspace"
  }
}

output "copilot_prompts" {
  description = "Paths to the GitHub Copilot prompt files for each repository"
  value = {
    master = try("${module.base_repo.github_repo.name}/.github/prompts/project-setup.prompt.md", null)
    repos = {
      for name, repo in module.project_repos : name => try("${repo.github_repo.name}/.github/prompts/repo-setup.prompt.md", null)
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
  description = "Map of repository names to their various URLs"
  value = merge(
    { (var.project_name) = {
      html_url = module.base_repo.github_repo.html_url
      ssh_url  = module.base_repo.ssh_clone_url
      http_url = module.base_repo.github_repo.http_clone_url
      git_url  = module.base_repo.github_repo.git_clone_url
    } },
    {
      for name, repo in module.project_repos : name => {
        html_url = repo.github_repo.html_url
        ssh_url  = repo.ssh_clone_url
        http_url = repo.github_repo.http_clone_url
        git_url  = repo.github_repo.git_clone_url
      }
    }
  )
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
  description = "Files created in the base repository"
  value = {
    managed_files = {
      for path, file in github_repository_file.base_repo_files : path => file.content
    }
    codeowners = try(github_repository_file.base_repo_codeowners[0].content, null)
  }
}
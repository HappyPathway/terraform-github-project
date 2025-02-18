output "master_repo" {
  description = "Information about the created master repository"
  value       = module.master_repo
}

output "project_repos" {
  description = "Map of created project repositories and their details"
  value       = module.project_repos
}

output "workspace_file_path" {
  description = "Path to the generated VS Code workspace file"
  value       = "${module.master_repo.full_name}/${var.project_name}.code-workspace"
}

output "copilot_prompts" {
  description = "Paths to the GitHub Copilot prompt files for each repository"
  value = {
    master = "${module.master_repo.full_name}/.github/prompts/project-setup.prompt.md"
    repos = {
      for name, repo in module.project_repos : name => "${repo.full_name}/.github/prompts/repo-setup.prompt.md"
    }
  }
}

output "all_repos" {
  description = "Combined list of all repositories including master repo"
  value = merge(
    { (var.project_name) = module.master_repo },
    module.project_repos
  )
}
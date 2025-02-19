variables {
  project_name = "test-project"
  project_prompt = "Test project prompt"
  repo_org = "HappyPathway"
  repositories = [
    {
      name = "test-repo"
      prompt = "Test repo prompt"
      github_repo_description = "Test repository"
      github_repo_topics = ["test", "terraform"]
      github_has_issues = true
      force_name = true
      create_repo = false
    }
  ]
  enforce_prs = true
}

run "initialize_project" {
  command = plan
}

run "verify_project_repos" {
  command = plan
  assert {
    condition     = module.master_repo.name == var.project_name
    error_message = "Master repo name does not match project name"
  }
  assert {
    condition     = module.project_repos["test-repo"].name == "test-repo"
    error_message = "Test repo name does not match expected"
  }
}
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
      force_name = true
      create_repo = false
    }
  ]
  enforce_prs = true
  workspace_files = []
}

run "verify_project_org" {
  command = plan

  plan_options {
    mode = refresh-only
  }

  assert {
    condition     = data.github_organization.org.login == "HappyPathway"
    error_message = "Organization name does not match expected"
  }
}

run "initialize_project" {
  command = plan

  assert {
    condition     = module.master_repo.github_repo.name == var.project_name
    error_message = "Master repo name does not match project name"
  }
}

run "verify_project_repos" {
  command = plan

  assert {
    condition     = module.project_repos["test-repo"].github_repo.name == "test-repo"
    error_message = "Test repo name does not match expected"
  }
}
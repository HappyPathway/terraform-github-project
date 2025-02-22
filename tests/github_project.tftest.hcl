mock_provider "github" {
  source = "./tests/mocks"
}

run "verify_base_project_config" {
  variables {
    project_name   = "test-project"
    project_prompt = "Test project configuration"
    repo_org       = "HappyPathway"
    repositories = [
      {
        name               = "test-service"
        github_repo_topics = ["test"]
        prompt             = "Test service repository"
      }
    ]
    base_repository = {
      visibility  = "public" # Required for GitHub Free tier
      create_repo = true
    }
  }

  assert {
    condition     = module.base_repo.github_repo.visibility == "public"
    error_message = "Base repository should be public for GitHub Free tier"
  }

  assert {
    condition     = module.base_repository_files.files["${var.project_name}.code-workspace"] != null
    error_message = "Workspace file should be created"
  }
}
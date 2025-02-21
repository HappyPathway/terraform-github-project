variables {
  project_name    = "test-project"
  repo_org        = "test-org"
  project_prompt  = "Test project for GitHub Free tier features"
}

run "verify_public_repository_features" {
  command = plan

  variables {
    repositories = [
      {
        name        = "public-repo"
        visibility  = "public"
        description = "Public repository with all features"
        enable_branch_protection = true
      }
    ]
  }

  assert {
    condition     = module.project_repos["public-repo"].github_repo.visibility == "public"
    error_message = "Repository should be public"
  }

  assert {
    condition     = length(github_branch_protection.project_repos) > 0
    error_message = "Branch protection should be enabled for public repository"
  }
}

run "verify_private_repository_limitations" {
  command = plan

  variables {
    repositories = [
      {
        name        = "private-repo"
        visibility  = "private"
        description = "Private repository with Free tier limitations"
      }
    ]
  }

  assert {
    condition     = module.project_repos["private-repo"].github_repo.visibility == "private"
    error_message = "Repository should be private"
  }

  assert {
    condition     = length(github_branch_protection.project_repos) == 0
    error_message = "Branch protection should be disabled for private repository in Free tier"
  }
}

run "verify_base_repository_defaults" {
  command = plan

  assert {
    condition     = module.base_repo.github_repo.visibility == "public"
    error_message = "Base repository should be public by default"
  }
}

run "verify_warning_file_creation" {
  command = plan

  variables {
    repositories = [
      {
        name        = "private-repo-with-warning"
        visibility  = "private"
        description = "Private repository that should include warning file"
      }
    ]
  }

  assert {
    condition     = contains(keys(module.project_repos["private-repo-with-warning"].managed_extra_files), ".github/FREE_TIER_LIMITATIONS.md")
    error_message = "Private repository should include Free tier limitations warning file"
  }
}

run "verify_validation_error_on_invalid_config" {
  command = plan

  variables {
    repositories = [
      {
        name        = "invalid-private-repo"
        visibility  = "private"
        enable_branch_protection = true
      }
    ]
  }

  expect_failures = [
    github_branch_protection.project_repos,
  ]
}
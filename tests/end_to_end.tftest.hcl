run "verify_end_to_end_repository_configuration" {
  variables {
    project_name = "e2e-test"
    repo_org = "test-org"
    project_prompt = "End-to-end test project"
    repositories = [
      {
        name = "app"
        github_repo_topics = [
          "typescript",
          "react",
          "docker",
          "kubernetes",
          "terraform",
          "jest"
        ]
        description = "Main application repository"
        allow_merge_commit = false
        allow_rebase_merge = true
        delete_branch_on_merge = true
      }
    ]

    security_config = {
      enable_security_scanning = true
      container_security_config = {
        scanning_tools = ["trivy"]
      }
    }

    development_config = {
      testing_requirements = {
        required = true
      }
      ci_cd_config = {
        required_status_checks = ["test", "lint"]
      }
    }

    quality_config = {
      linting_required = true
      type_safety = true
    }
  }

  # Verify repository creation and settings
  assert {
    condition = github_repository.project_repos["app"].allow_merge_commit == false
    error_message = "Repository merge settings should be properly configured"
  }

  assert {
    condition = github_repository.project_repos["app"].delete_branch_on_merge == true
    error_message = "Branch cleanup settings should be properly configured"
  }

  # Verify branch protection
  assert {
    condition = length(github_branch_protection.protection["app"].required_status_checks) > 0
    error_message = "Branch protection should include required status checks"
  }

  # Verify file creation
  assert {
    condition = length(github_repository_file.workflow["app"].content) > 0
    error_message = "GitHub Actions workflow should be created"
  }

  assert {
    condition = length(github_repository_file.devcontainer["app"].content) > 0
    error_message = "DevContainer configuration should be created"
  }

  # Verify security configuration
  assert {
    condition = contains(jsondecode(github_repository_file.workflow["app"].content).jobs.security.steps[*].uses, "aquasecurity/trivy-action")
    error_message = "Security scanning workflow should include Trivy"
  }
}
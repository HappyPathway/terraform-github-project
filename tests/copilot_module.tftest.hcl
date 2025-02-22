mock_provider "github" {
  source = "./tests/mocks"
}

run "verify_language_detection" {
  command = plan

  variables {
    project_name   = "test-copilot-lang"
    project_prompt = "Test project for language detection"
    repo_org       = "test-org"
    repositories = [
      {
        name               = "backend-api"
        github_repo_topics = ["python", "fastapi", "pytest", "docker"]
        prompt             = "Backend API service with Python and FastAPI"
      },
      {
        name               = "frontend-app"
        github_repo_topics = ["typescript", "react", "jest", "eslint"]
        prompt             = "Frontend application with React and TypeScript"
      }
    ]
  }

  assert {
    condition     = contains(module.copilot.detected_languages, "python")
    error_message = "Should detect Python language from repository topics"
  }

  assert {
    condition     = contains(module.copilot.detected_languages, "typescript")
    error_message = "Should detect TypeScript language from repository topics"
  }
}

run "verify_testing_tools_detection" {
  command = plan

  variables {
    project_name   = "test-copilot-test"
    project_prompt = "Test project for testing tools detection"
    repo_org       = "test-org"
    repositories = [
      {
        name               = "test-copilot-service"
        github_repo_topics = ["python", "pytest", "jest"]
        prompt             = "Service with multiple testing frameworks"
      }
    ]
  }

  assert {
    condition     = contains(module.copilot.detected_testing_tools, "pytest")
    error_message = "Should detect pytest from repository topics"
  }
}

run "verify_infrastructure_detection" {
  command = plan

  variables {
    project_name   = "test-copilot-infra"
    project_prompt = "Test project for infrastructure detection"
    repo_org       = "test-org"
    repositories = [
      {
        name               = "infrastructure"
        github_repo_topics = ["terraform", "aws"]
        prompt             = "Infrastructure as code"
      }
    ]
  }

  assert {
    condition     = contains(module.copilot.detected_iac_tools, "terraform")
    error_message = "Should detect Terraform from repository topics"
  }
}

run "verify_repo_settings" {
  command = plan

  variables {
    project_name   = "test-repo-settings"
    project_prompt = "Test project for repository settings"
    repo_org       = "test-org"
    repositories = [
      {
        name               = "test-repo"
        github_repo_topics = ["python"]
        prompt             = "Test repository"
      }
    ]
  }
  # module.base_repository_files
  # Testing repository configuration inputs
  assert {
    condition     = module.base_repository_files.files[".github/copilot-instructions.md"] != null
    error_message = "Should create copilot instructions file"
  }
}

run "verify_workspace_file_creation" {
  command = plan

  variables {
    project_name   = "test-workspace"
    project_prompt = "Test project for workspace file"
    repo_org       = "test-org"
    repositories = [
      {
        name               = "test-repo"
        github_repo_topics = ["python"]
        prompt             = "Test repository"
      }
    ]
    vs_code_workspace = {
      settings = {
        "editor.formatOnSave" : true
      }
      extensions = {
        recommended = ["ms-python.python"]
      }
    }
  }

  # Testing planned file creation rather than content
  assert {
    condition     = can(module.base_repository_files.files["test-workspace.code-workspace"])
    error_message = "Workspace file should be planned for creation"
  }
}
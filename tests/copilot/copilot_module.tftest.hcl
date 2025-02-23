mock_provider "github" {
  source = "../mocks"
}

run "verify_language_detection" {
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
    condition     = contains(module.development.detected_languages, "python")
    error_message = "Should detect Python language from repository topics"
  }

  assert {
    condition     = contains(module.development.detected_languages, "typescript")
    error_message = "Should detect TypeScript language from repository topics"
  }
}

run "verify_testing_tools_detection" {
  variables {
    project_name   = "test-copilot-test"
    project_prompt = "Test project for testing tools detection"
    repo_org       = "test-org"
    repositories = [
      {
        name               = "test-service"
        github_repo_topics = ["python", "pytest", "jest"]
        prompt             = "Service with multiple testing frameworks"
      }
    ]
  }

  assert {
    condition     = contains(module.development.detected_testing_tools, "pytest")
    error_message = "Should detect pytest from repository topics"
  }
}

run "verify_infrastructure_detection" {
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
    condition     = contains(module.development.detected_iac_tools, "terraform")
    error_message = "Should detect Terraform from repository topics"
  }
}

run "verify_file_creation" {
  variables {
    project_name   = "test-copilot-files"
    project_prompt = "Test project for file creation"
    repo_org       = "test-org"
    repositories = [
      {
        name               = "test-repo"
        github_repo_topics = ["python"]
        prompt             = "Test repository for file creation"
      }
    ]
  }

  assert {
    condition     = module.project_repository_files["test-repo"].files[".github/copilot-instructions.md"] != null
    error_message = "Should create copilot-instructions.md file"
  }

  assert {
    condition     = module.project_repository_files["test-repo"].files[".github/prompts/test-repo.prompt.md"] != null
    error_message = "Should create prompt file in .github/prompts"
  }
}

run "verify_base_repo_copilot_file" {
  variables {
    project_name   = "test-copilot-base"
    project_prompt = "Test project for base repo Copilot file"
    repo_org       = "test-org"
    repositories   = []
  }

  assert {
    condition     = module.base_repository_files.files[".github/copilot-instructions.md"].content == module.copilot.copilot_instructions
    error_message = "Should add Copilot instructions file to base repository"
  }
}

run "verify_workspace_file_creation" {
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

  assert {
    condition     = module.base_repository_files.files["test-workspace.code-workspace"] != null
    error_message = "Workspace file should be created in base repository"
  }

  assert {
    condition = contains(
      jsondecode(module.base_repository_files.files["test-workspace.code-workspace"].content).extensions.recommendations,
      "github.copilot"
    )
    error_message = "Workspace file should include github.copilot extension"
  }
}

run "verify_repo_settings" {
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

  assert {
    condition     = module.base_repository_files.files[".github/prompts/copilot-instructions.prompt.md"] != null
    error_message = "Should create copilot instructions file"
  }

  assert {
    condition     = module.base_repository_files.files[".github/prompts/copilot-instructions.prompt.md"].content == module.copilot.copilot_instructions
    error_message = "Should add Copilot instructions file to base repository"
  }
}
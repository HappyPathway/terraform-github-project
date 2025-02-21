mock_provider "github" {
  source = "./tests/mocks"
}

run "verify_language_detection" {
  variables {
    project_name = "test-copilot-${uuid()}"
    repo_org = "test-org"
    project_prompt = "Test project for language detection"
    repositories = [
      {
        name = "backend-api-${uuid()}"
        github_repo_topics = ["python", "fastapi", "pytest", "docker"]
        prompt = "Backend API service with Python and FastAPI"
      },
      {
        name = "backend-api-${uuid()}"
        github_repo_topics = ["typescript", "react", "jest", "eslint"]
        prompt = "Frontend application with React and TypeScript"
      }
    ]
    github_pro_enabled = false
    enforce_prs = true
  }

  assert {
    condition = contains(module.development.detected_languages, "python")
    error_message = "Should detect Python language from repository topics"
  }

  assert {
    condition = contains(module.development.detected_languages, "typescript")
    error_message = "Should detect TypeScript language from repository topics"
  }

  assert {
    condition = contains(module.development.detected_frameworks, "fastapi")
    error_message = "Should detect FastAPI framework from repository topics"
  }

  assert {
    condition = contains(module.development.detected_frameworks, "react")
    error_message = "Should detect React framework from repository topics"
  }
}

run "verify_testing_tools_detection" {
  variables {
    project_name = "test-copilot-${uuid()}"
    project_prompt = "Test project for testing tools detection"
    repo_org = "test-org"
    github_pro_enabled = false
    enforce_prs = true
    repositories = [
      {
        name = "test-service-${uuid()}"
        github_repo_topics = ["python", "pytest", "jest"]
        prompt = "Service with multiple testing frameworks"
      }
    ]
  }

  assert {
    condition = contains(module.development.detected_testing_tools, "pytest")
    error_message = "Should detect pytest from repository topics"
  }

  assert {
    condition = contains(module.development.detected_testing_tools, "jest")
    error_message = "Should detect jest from repository topics"
  }
}

run "verify_infrastructure_detection" {
  variables {
    project_name = "test-copilot-${uuid()}"
    project_prompt = "Test project for infrastructure detection"
    repo_org = "test-org"
    github_pro_enabled = false
    enforce_prs = true
    repositories = [
      {
        name = "infrastructure-${uuid()}"
        github_repo_topics = ["terraform", "aws", "pulumi"]
        prompt = "Infrastructure as code with multiple tools"
      }
    ]

  }

  assert {
    condition = contains(module.development.detected_iac_tools, "terraform")
    error_message = "Should detect Terraform from repository topics"
  }

  assert {
    condition = contains(module.development.detected_iac_tools, "pulumi")
    error_message = "Should detect Pulumi from repository topics"
  }

  assert {
    condition = contains(module.development.detected_cloud_providers, "aws")
    error_message = "Should detect AWS from repository topics"
  }
}

run "verify_file_creation" {
  variables {
    project_name = "test-copilot-${uuid()}"
    project_prompt = "Test project for file creation"
    repo_org = "test-org"
    repositories = [
      {
        name = "test-repo-${uuid()}"
        github_repo_topics = ["python"]
        prompt = "Test repository for file creation"
      }
    ]
    github_pro_enabled = false
    enforce_prs = true
  }

  assert {
    condition = module.development.copilot_instructions["test-repo"].file == ".github/copilot-instructions.md"
    error_message = "Should create copilot instructions file in correct location"
  }

  assert {
    condition = module.development.repo_prompt["test-repo"].file == ".github/prompts/repo-setup.prompt.md"
    error_message = "Should create repository prompt file in correct location"
  }

  assert {
    condition = module.development.repo_prompt["test-repo"].content == "Test repository for file creation"
    error_message = "Should set correct content for repository prompt"
  }
}

run "verify_github_pro_handling" {
  variables {
    project_name = "test-copilot-${uuid()}"
    project_prompt = "Test project for GitHub Pro handling"
    repo_org = "test-org"
    repositories = [
      {
        name = "private-repo-${uuid()}"
        github_repo_topics = ["python"]
        prompt = "Private repository test"
      }
    ]
    github_pro_enabled = false
    enforce_prs = true
  }

  assert {
    condition = contains(module.development.github_pro_notices, "Branch protection requires public repositories or GitHub Pro")
    error_message = "Should include GitHub Pro limitation notice in instructions when not enabled"
  }
}
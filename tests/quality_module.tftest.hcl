mock_provider "github" {
  source = "./tests/mocks"
}

run "verify_code_quality_requirements" {
  variables {
    project_name   = "test-quality"
    project_prompt = "Test project for quality requirements"
    repo_org       = "HappyPathway"
    repositories = [
      {
        name               = "typescript-service"
        github_repo_topics = ["typescript", "eslint", "prettier", "jest"]
        prompt             = "TypeScript service with strict quality requirements"
      }
    ]

    quality_config = {
      linting_required       = true
      type_safety            = true
      documentation_required = true
      formatting_tools       = ["prettier", "eslint"]
    }
  }

  assert {
    condition     = module.quality.code_quality_config.linting_required
    error_message = "Should require linting based on configuration"
  }

  assert {
    condition     = module.quality.code_quality_config.type_safety
    error_message = "Should enforce type safety based on configuration"
  }

  assert {
    condition     = module.quality.code_quality_config.documentation_required
    error_message = "Should require documentation based on configuration"
  }

  assert {
    condition     = length(module.quality.detected_formatting_tools) > 0
    error_message = "Should detect formatting tools from repository topics"
  }
}

run "verify_quality_tools_detection" {
  variables {
    project_name   = "test-quality-tools"
    project_prompt = "Test project for quality tools detection"
    repo_org       = "test-org"
    repositories = [
      {
        name               = "python-app"
        github_repo_topics = ["python", "black", "flake8", "mypy", "sphinx"]
        prompt             = "Python application with quality tools"
      }
    ]
  }

  assert {
    condition     = contains(module.quality.detected_linting_tools, "flake8")
    error_message = "Should detect Python linting tools"
  }

  assert {
    condition     = contains(module.quality.detected_formatting_tools, "black")
    error_message = "Should detect Python formatting tools"
  }

  assert {
    condition     = contains(module.quality.detected_documentation_tools, "sphinx")
    error_message = "Should detect documentation tools"
  }
}
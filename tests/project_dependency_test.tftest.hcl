# Project Tests
run "validate_repository_configuration" {
  command = plan

  variables {
    project_name = "test-multi-repo"
    repo_org     = "test-org"
    project_prompt = "Test project for repository configuration"
    
    base_repository = {
      name = "test-multi-repo"
      description = "Test project for repository configuration"
      visibility = "public"
    }

    repositories = [
      {
        name = "service-c"
        description = "Service C repository"
      },
      {
        name = "service-d"
        description = "Service D repository"
      },
      {
        name = "service-e"
        description = "Service E repository"
      }
    ]
  }
}

run "repository_structure" {
  command = plan

  variables {
    project_name = "test-multi-repo"
    repo_org     = "test-org"
    project_prompt = "Test project for repository structure"

    base_repository = {
      name = "test-multi-repo"
      description = "Test project for repository structure"
      visibility = "public"
    }

    repositories = [
      {
        name = "service-x"
        description = "Service X repository"
      },
      {
        name = "service-y"
        description = "Service Y repository"
      },
      {
        name = "service-z"
        description = "Service Z repository"
      }
    ]
  }
}

run "validate_prompt_feature_flags" {
  command = plan

  variables {
    base_repository = {
      name = "test-multi-repo"
      description = "Test project for prompt feature detection"
      visibility = "public"
    }
    repo_org = "test-org"
    project_name = "test-multi-repo"
    project_prompt = "Create a microservices project with observability using OpenTelemetry, containerization with Docker, and CI/CD using GitHub Actions."
  }

  // Verify OpenTelemetry configuration is present
  assert {
    condition = contains(keys(module.base_repository_files.files), "opentelemetry.yml")
    error_message = "OpenTelemetry configuration should be present when observability is requested"
  }

  // Verify Docker configuration
  assert {
    condition = alltrue([
      contains(keys(module.base_repository_files.files), "Dockerfile"),
      contains(keys(module.base_repository_files.files), "docker-compose.yml")
    ])
    error_message = "Docker configuration files should be present when containerization is requested"
  }

  // Verify GitHub Actions workflows
  assert {
    condition = alltrue([
      contains(keys(module.base_repository_files.files), ".github/workflows/build.yml"),
      contains(keys(module.base_repository_files.files), ".github/workflows/deploy.yml")
    ])
    error_message = "GitHub Actions workflow files should be present when CI/CD is requested"
  }
}
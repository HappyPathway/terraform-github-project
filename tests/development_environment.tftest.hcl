provider "github" {}

run "development_environment_configuration" {
  command = plan

  variables {
    project_name = "test-dev-env"
    repo_org     = "test-org"

    base_repository = {
      name        = "test-dev-env"
      description = "Test project for development environment"
    }

    repositories = [
      {
        name        = "test-service"
        description = "Test service repository"
      }
    ]

    development_container = {
      base_image = "python:3.11"
      install_tools = ["pip", "git"]
      vs_code_extensions = ["ms-python.python"]
      env_vars = {
        ENVIRONMENT = "test"
      }
      ports = ["8000:8000"]
    }

    vs_code_workspace = {
      settings = {
        "editor.formatOnSave": true
      }
      extensions = {
        recommended = ["ms-python.python"]
      }
    }

    codespaces = {
      machine_type = "medium"
      prebuild_enabled = true
    }
  }

  assert {
    condition = contains(keys(output.repository_names), "test-service")
    error_message = "Repository was not created correctly"
  }
}

run "validate_devcontainer_files" {
  command = plan

  variables {
    project_name = "test-dev-env"
    repo_org     = "test-org"

    base_repository = {
      name        = "test-dev-env"
      description = "Test project for development environment"
    }

    repositories = [
      {
        name        = "test-service"
        description = "Test service repository"
      }
    ]

    development_container = {
      base_image = "python:3.11"
      docker_compose = {
        enabled = true
        services = {
          redis = {
            image = "redis:alpine"
            ports = ["6379:6379"]
            environment = {
              REDIS_MAXMEMORY = "512mb"
            }
          }
        }
      }
    }
  }

  assert {
    condition = length(github_repository_file.devcontainer) > 0
    error_message = "DevContainer configuration file was not created"
  }

  assert {
    condition = length(github_repository_file.docker_compose) > 0
    error_message = "Docker Compose configuration file was not created"
  }
}

run "validate_workspace_config" {
  command = plan

  variables {
    project_name = "test-dev-env"
    repo_org     = "test-org"

    base_repository = {
      name        = "test-dev-env"
      description = "Test project for development environment"
    }

    repositories = [
      {
        name        = "test-service"
        description = "Test service repository"
      }
    ]

    vs_code_workspace = {
      settings = {
        "editor.formatOnSave": true
      }
      extensions = {
        recommended = ["ms-python.python"]
        required = ["github.copilot"]
      }
      tasks = [
        {
          name = "Test Task"
          command = "echo 'test'"
          group = "test"
        }
      ]
    }
  }

  assert {
    condition = local_file.workspace_config.filename == "${var.project_name}.code-workspace"
    error_message = "Workspace configuration file was not created with correct name"
  }
}

run "development_features_disabled_by_default" {
  command = plan

  variables {
    project_name = "test-dev-env"
    repo_org     = "test-org"

    base_repository = {
      name        = "test-dev-env"
      description = "Test project for development environment"
    }

    repositories = [
      {
        name        = "test-service"
        description = "Test service repository"
      }
    ]
  }

  assert {
    condition     = length(github_repository_file.devcontainer) == 0
    error_message = "DevContainer files should not be created when feature is not explicitly enabled"
  }

  assert {
    condition     = length(github_repository_file.docker_compose) == 0
    error_message = "Docker Compose files should not be created when feature is not explicitly enabled"
  }

  assert {
    condition     = length(github_repository_file.codespaces) == 0
    error_message = "Codespaces configuration should not be created when feature is not explicitly enabled"
  }

  assert {
    condition     = length(local_file.workspace_config) == 0
    error_message = "VS Code workspace file should not be created when feature is not explicitly enabled"
  }
}

run "workspace_file_always_created" {
  command = plan

  variables {
    project_name = "test-dev-env"
    repo_org     = "test-org"

    base_repository = {
      name        = "test-dev-env"
      description = "Test project for development environment"
    }

    repositories = [
      {
        name        = "test-service"
        description = "Test service repository"
      }
    ]
  }

  assert {
    condition     = length(github_repository_file.workspace_config) == 1
    error_message = "VS Code workspace file should always be created in base repository"
  }

  assert {
    condition     = github_repository_file.workspace_config[0].file == "test-dev-env.code-workspace"
    error_message = "VS Code workspace file should have correct name"
  }

  assert {
    condition     = github_repository_file.workspace_config[0].repository == "test-dev-env"
    error_message = "VS Code workspace file should be created in base repository"
  }
}

run "workspace_file_settings" {
  command = plan

  variables {
    project_name = "test-dev-env"
    repo_org     = "test-org"

    base_repository = {
      name        = "test-dev-env"
      description = "Test project for development environment"
    }

    repositories = [
      {
        name        = "test-service"
        description = "Test service repository"
      }
    ]

    vs_code_workspace = {
      settings = {
        "editor.formatOnSave": true
      }
      extensions = {
        recommended = ["ms-python.python"]
        required = ["github.copilot"]
      }
    }
  }

  assert {
    condition     = contains(jsondecode(github_repository_file.workspace_config[0].content).extensions.recommendations, "ms-python.python")
    error_message = "VS Code workspace file should include custom extensions when provided"
  }

  assert {
    condition     = contains(jsondecode(github_repository_file.workspace_config[0].content).extensions.recommendations, "github.copilot")
    error_message = "VS Code workspace file should always include github.copilot extension"
  }
}
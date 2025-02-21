mock_provider "github" {
  source = "./tests/mocks"
}

run "development_environment_configuration" {
  command = plan

  variables {
    project_name = "test-dev-env"
    repo_org     = "test-org"
    github_pro_enabled = false
    project_prompt = "This is a test project for development environment configuration"

    base_repository = {
      name        = "test-dev-env"
      description = "Test project for development environment"
      visibility  = "public"
    }

    repositories = [
      {
        name        = "test-service"
        description = "Test service repository"
        visibility  = "public"
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
  }

  assert {
    condition = output.repository_names[0] == "test-service"
    error_message = "Repository test-service was not created"
  }
}

run "validate_devcontainer_files" {
  command = plan

  variables {
    project_name = "test-dev-env"
    repo_org     = "test-org"
    github_pro_enabled = false
    project_prompt = "This is a test project for development environment configuration"

    base_repository = {
      name        = "test-dev-env"
      description = "Test project for development environment"
      visibility  = "public"
    }

    repositories = [
      {
        name        = "test-service"
        description = "Test service repository"
        visibility  = "public"
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
              REDIS_ARGS = "--maxmemory 512mb"
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
    github_pro_enabled = false
    project_prompt = "This is a test project for development environment configuration"

    base_repository = {
      name        = "test-dev-env"
      description = "Test project for development environment"
      visibility  = "public"
    }

    repositories = [
      {
        name        = "test-service"
        description = "Test service repository"
        visibility  = "public"
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
    condition = github_repository_file.workspace_config[0].file == "${var.project_name}.code-workspace"
    error_message = "Workspace configuration file was not created with correct name"
  }

  assert {
    condition = contains(jsondecode(github_repository_file.workspace_config[0].content).extensions.recommendations, "ms-python.python")
    error_message = "VS Code workspace file should include configured extensions"
  }
}

run "development_features_disabled_by_default" {
  command = plan

  variables {
    project_name = "test-dev-env"
    repo_org     = "test-org"
    github_pro_enabled = false
    project_prompt = "test prompt for testing development environment configuration"
    base_repository = {
      name        = "test-dev-env"
      description = "Test project for development environment"
      visibility  = "public"
    }

    repositories = [
      {
        name        = "test-service"
        description = "Test service repository"
        visibility  = "public"
      }
    ]
  }

  assert {
    condition = length(github_repository_file.devcontainer) == 0
    error_message = "DevContainer files should not be created when feature is not explicitly enabled"
  }

  assert {
    condition = length(github_repository_file.docker_compose) == 0
    error_message = "Docker Compose files should not be created when feature is not explicitly enabled"
  }
}

run "workspace_file_always_created" {
  command = plan

  variables {
    project_name = "test-dev-env"
    repo_org     = "test-org"
    github_pro_enabled = false
    project_prompt = "test prompt for testing development environment configuration"
    base_repository = {
      name        = "test-dev-env"
      description = "Test project for development environment"
      visibility  = "public"
    }

    repositories = [
      {
        name        = "test-service"
        description = "Test service repository"
        visibility  = "public"
      }
    ]
  }

  assert {
    condition = length(github_repository_file.workspace_config) == 1
    error_message = "VS Code workspace file should always be created in base repository"
  }

  assert {
    condition = github_repository_file.workspace_config[0].file == "test-dev-env.code-workspace"
    error_message = "VS Code workspace file should have correct name"
  }

  assert {
    condition = github_repository_file.workspace_config[0].repository == "test-dev-env"
    error_message = "VS Code workspace file should be created in base repository"
  }
}
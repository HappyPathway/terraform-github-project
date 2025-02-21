mock_provider "github" {
  source = "./mocks"
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
      visibility  = "public"  # Required for GitHub Free
    }

    repositories = [
      {
        name        = "test-service"
        description = "Test service repository"
        visibility  = "public"  # Required for GitHub Free
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

run "validate_repository_files" {
  command = plan

  variables {
    project_name = "test-dev-env"
    repo_org     = "test-org"
    github_pro_enabled = false
    project_prompt = "This is a test project for development environment configuration"
    
    base_repository = {
      name        = "test-dev-env"
      description = "Test project for development environment"
      visibility  = "public"  # Required for GitHub Free
    }

    repositories = [
      {
        name        = "test-service"
        description = "Test service repository"
        visibility  = "public"  # Required for GitHub Free
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
    condition = contains(module.base_repository_files.file_paths, ".devcontainer/devcontainer.json")
    error_message = "DevContainer configuration file was not created"
  }

  assert {
    condition = contains(module.base_repository_files.file_paths, ".devcontainer/docker-compose.yml")
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
      visibility  = "public"  # Required for GitHub Free
    }

    repositories = [
      {
        name        = "test-service"
        description = "Test service repository"
        visibility  = "public"  # Required for GitHub Free
      }
    ]

    vs_code_workspace = {
      settings = {
        "editor.formatOnSave": true
      }
      extensions = {
        recommended = ["ms-python.python"]
      }
      tasks = [
        {
          name = "Test Task",
          type = "shell",
          command = "echo 'test'",
          group = "test"
        }
      ]
    }
  }

  assert {
    condition = contains(module.base_repository_files.file_paths, "${var.project_name}.code-workspace")
    error_message = "Workspace configuration file was not created with correct name"
  }

  assert {
    condition = contains(jsondecode(module.base_repository_files.files["${var.project_name}.code-workspace"].content).extensions.recommendations, "ms-python.python")
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
      visibility  = "public"  # Required for GitHub Free
    }

    repositories = [
      {
        name        = "test-service"
        description = "Test service repository"
        visibility  = "public"  # Required for GitHub Free
      }
    ]
  }

  assert {
    condition = !contains(module.base_repository_files.file_paths, ".devcontainer/devcontainer.json")
    error_message = "DevContainer files should not be created when feature is not explicitly enabled"
  }

  assert {
    condition = !contains(module.base_repository_files.file_paths, ".devcontainer/docker-compose.yml") 
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
      visibility  = "public"  # Required for GitHub Free
    }

    repositories = [
      {
        name        = "test-service"
        description = "Test service repository"
        visibility  = "public"  # Required for GitHub Free
      }
    ]
  }

  assert {
    condition = contains(module.base_repository_files.file_paths, "${var.project_name}.code-workspace")
    error_message = "VS Code workspace file should always be created in base repository"
  }
}
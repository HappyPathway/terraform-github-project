mock_provider "github" {
  source = "./tests/mocks"
}

run "verify_complete_module_integration" {
  command = plan

  variables {
    project_name = "test-integration"
    repo_org     = "test-org"
    github_pro_enabled = false
    project_prompt = "Test project for module integration"

    base_repository = {
      name        = "test-integration"
      description = "Test project for module integration"
      visibility  = "public"  // Required for branch protection with GitHub Free
    }

    repositories = [
      {
        name        = "test-service"
        description = "Test service repository"
        visibility  = "public"  // Required for branch protection with GitHub Free
      }
    ]

    development_container = {
      base_image = "python:3.11"
      install_tools = ["pip", "git"]
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

  assert {
    condition = contains(module.base_repository_files.file_paths, "${var.project_name}.code-workspace")
    error_message = "Workspace configuration file was not created"
  }
}

run "development_environment_defaults" {
  command = plan 

  variables {
    project_name = "test-defaults"
    repo_org = "test-org"
    github_pro_enabled = false
    project_prompt = "Testing development environment defaults"

    base_repository = {
      name = "test-defaults"
      description = "Test defaults project"
      visibility = "public"
    }

    repositories = []
  }

  # Update assertions to use module.base_repository_files
  assert {
    condition = !contains(module.base_repository_files.file_paths, ".devcontainer/devcontainer.json")
    error_message = "DevContainer should not be created by default"
  }

  assert {
    condition = contains(module.base_repository_files.file_paths, "${var.project_name}.code-workspace")
    error_message = "VS Code workspace file should always be created"
  }
}

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

  # Only test basic branch protection
  assert {
    condition = length(github_branch_protection.project_repos) > 0 && github_branch_protection.project_repos[0].pattern == "main"
    error_message = "Basic branch protection was not configured properly"
  }

  assert {
    condition = length(github_repository_file.workspace_config) == 1
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

  assert {
    condition = length(github_repository_file.devcontainer) == 0
    error_message = "DevContainer should not be created by default"
  }

  assert {
    condition = length(github_repository_file.workspace_config) == 1
    error_message = "VS Code workspace file should always be created"
  }
}

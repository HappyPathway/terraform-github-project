mock_provider "github" {
  source = "./tests/mocks"
}

run "verify_end_to_end_repository_configuration" {
  variables {
    project_name = "test-e2e"  // Use static name for predictable testing
    repo_org = "test-org"
    project_prompt = "End-to-end test project"
    github_pro_enabled = false
    base_repository = {
      name = "test-e2e"
      visibility = "public"  // Required for branch protection with GitHub Free
      description = "Test base repository"
    }
    repositories = [
      {
        name = "app-test-${uuid()}"
        github_repo_topics = [
          "typescript",
          "react",
          "docker",
          "kubernetes",
          "terraform",
          "jest"
        ]
        description = "Test application repository"
        visibility = "public"  // Required for branch protection with GitHub Free
        allow_merge_commit = false
        allow_rebase_merge = true
        delete_branch_on_merge = true
        prompt = "Test application repository for end-to-end testing"
      }
    ]

    vs_code_workspace = {
      settings = {
        "editor.formatOnSave": true
      }
      extensions = {
        recommended = ["ms-python.python"]
      }
    }

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

  # Verify repository file creation using new module outputs
  assert {
    condition = contains(module.base_repository_files.file_paths, "test-e2e.code-workspace")
    error_message = "Workspace configuration file should be created"
  }

  assert {
    condition = contains(module.base_repository_files.file_paths, ".devcontainer/devcontainer.json")
    error_message = "DevContainer configuration should be created"
  }

  assert {
    condition = contains(module.base_repository_files.file_paths, ".devcontainer/docker-compose.yml")
    error_message = "Docker Compose configuration should be created"
  }
}
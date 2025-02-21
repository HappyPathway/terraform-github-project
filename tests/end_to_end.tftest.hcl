variables {
  project_name = "test-e2e-${replace(uuid(), "-", "")}"  // Make project name unique
  repo_org = "test-org"
  project_prompt = "End-to-end test project"
  github_pro_enabled = false
}

run "verify_end_to_end_repository_configuration" {
  command = plan  // Use plan to avoid actual resource creation

  variables {
    base_repository = {
      name = var.project_name  // Use dynamic project name
      visibility = "public"  // Required for branch protection with GitHub Free
      description = "Test base repository"
      archive_on_destroy = false
    }
    repositories = [
      {
        name = "app-${replace(uuid(), "-", "")}"  // Make repo name unique
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
    condition = contains(module.base_repository_files.file_paths, "${var.project_name}.code-workspace")
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
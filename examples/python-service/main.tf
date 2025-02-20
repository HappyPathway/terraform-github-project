# Description: Example usage of the python-service moduleterraform {
terraform {
  backend "gcs" {
    bucket = "hpw-terraform-state"
    prefix = "github-projects/python-service"
  }

  required_providers {
    github = {
      source  = "integrations/github"
    }
  }
}

module "python_project" {
  source = "../../"

  project_name = "python-service"
  repo_org     = "example-org"
  project_prompt = "Python microservice project with development environment configuration"
  base_repository = {
    name        = "python-service"
    description = "Python microservice project with development environment configuration"
  }

  repositories = [
    {
      name        = "service-api"
      description = "Main API service"
    },
    {
      name        = "service-worker"
      description = "Background worker service"
    }
  ]

  development_container = {
    base_image = "python:3.11"
    install_tools = [
      "pip",
      "poetry",
      "make",
      "git"
    ]
    vs_code_extensions = [
      "ms-python.python",
      "ms-python.vscode-pylance",
      "ms-python.black-formatter",
      "github.copilot"
    ]
    env_vars = {
      PYTHONPATH = "/workspace"
      ENVIRONMENT = "development"
    }
    ports = ["8000:8000", "5000:5000"]
    post_create_commands = [
      "python -m pip install --upgrade pip",
      "poetry config virtualenvs.in-project true",
      "poetry install"
    ]
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
        postgres = {
          image = "postgres:14-alpine"
          ports = ["5432:5432"]
          environment = {
            POSTGRES_USER = "dev"
            POSTGRES_PASSWORD = "dev"
            POSTGRES_DB = "app"
          }
        }
      }
    }
  }

  vs_code_workspace = {
    settings = {
      "python.defaultInterpreterPath" = ".venv/bin/python",
      "python.formatting.provider" = "black",
      "editor.formatOnSave" = true,
      "editor.rulers" = [88, 100],
      "files.trimTrailingWhitespace" = true
    }
    extensions = {
      recommended = [
        "ms-python.python",
        "ms-python.vscode-pylance",
        "ms-python.black-formatter",
        "github.copilot"
      ]
      required = ["github.copilot"]
    }
    tasks = [
      {
        name = "Install Dependencies"
        command = "poetry install"
        group = "build"
      },
      {
        name = "Run Tests"
        command = "poetry run pytest"
        group = "test"
      },
      {
        name = "Format Code"
        command = "poetry run black ."
        group = "none"
      }
    ]
    launch_configurations = [
      {
        name = "Python: FastAPI"
        type = "python"
        request = "launch"
        configuration = {
          module = "uvicorn"
          args = ["app.main:app", "--reload", "--port", "8000"]
          justMyCode = false
        }
      }
    ]
  }

  codespaces = {
    machine_type = "medium"
    retention_days = 30
    prebuild_enabled = true
    env_vars = {
      PYTHON_VERSION = "3.11"
      POETRY_VIRTUALENVS_IN_PROJECT = "true"
    }
    secrets = ["DEV_DATABASE_URL", "DEV_REDIS_URL"]
  }
}
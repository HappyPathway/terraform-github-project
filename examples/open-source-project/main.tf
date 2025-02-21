terraform {
  backend "gcs" {
    bucket = "hpw-terraform-state"
    prefix = "github-projects/open-source-project"
  }

  required_providers {
    github = {
      source = "integrations/github"
    }
  }
}

module "open_source_project" {
  source = "../../"

  project_name    = "awesome-library"
  repo_org        = "my-org"
  project_prompt  = "Open source library with extensive documentation and examples"

  # Base repository is public by default
  base_repository = {
    description = "Main repository for Awesome Library project"
    topics      = ["open-source", "documentation"]
    pages = {
      branch = "gh-pages"  # Enable GitHub Pages for documentation
      path   = "/docs"
    }
  }

  repositories = [
    {
      name        = "core-library"
      description = "Core library implementation"
      topics      = ["library", "core"]
      # Public by default - enables all GitHub Free features
      gitignore_template = "Node"
      branch_protection = {
        required_status_checks = {
          contexts = ["unit-tests", "integration-tests", "lint"]
        }
        required_approving_review_count = 1
      }
    },
    {
      name        = "examples"
      description = "Example implementations and usage guides"
      topics      = ["examples", "tutorials"]
      # Public by default - enables all GitHub Free features
      branch_protection = {
        required_status_checks = {
          contexts = ["build", "test"]
        }
      }
    },
    {
      name        = "internal-tools"
      description = "Internal development tools and scripts"
      visibility  = "private"  # Private repo with Free tier limitations
      topics      = ["tools", "internal"]
      # Branch protection automatically disabled for Free tier
      # Warning file will be added automatically
    }
  ]

  # Development container configuration
  development_container = {
    base_image = "node:18"
    install_tools = [
      "git",
      "npm"
    ]
    vs_code_extensions = [
      "dbaeumer.vscode-eslint",
      "esbenp.prettier-vscode",
      "github.copilot"
    ]
    env_vars = {
      NODE_ENV = "development"
    }
  }

  # Environment configuration
  environments = {
    "core-library" = [
      {
        name = "npm-publish"
        reviewers = {
          teams = ["library-maintainers"]
        }
      }
    ]
  }
}
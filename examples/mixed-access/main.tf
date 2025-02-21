terraform {
  backend "gcs" {
    bucket = "hpw-terraform-state"
    prefix = "github-projects/mixed-access"
  }

  required_providers {
    github = {
      source = "integrations/github"
    }
  }
}

module "mixed_access_project" {
  source = "../../"

  project_name    = "my-saas-app"
  repo_org        = "my-org"
  project_prompt  = "SaaS application with public SDK and private backend services"

  # Base repository is public for maximum visibility
  base_repository = {
    description = "My SaaS Application - Public SDK and Documentation"
    topics      = ["saas", "sdk", "api"]
    pages = {
      branch = "gh-pages"
      path   = "/docs"
    }
  }

  repositories = [
    {
      name        = "public-sdk"
      description = "Public SDK for API integration"
      topics      = ["sdk", "api-client", "documentation"]
      # Public repository with all features enabled
      branch_protection = {
        required_status_checks = {
          contexts = ["build", "test", "lint"]
        }
        required_approving_review_count = 1
      }
      extra_files = [
        {
          path = "CONTRIBUTING.md"
          content = <<-EOT
# Contributing Guidelines

This repository uses GitHub Free features for public repositories:
- All pull requests require review
- CI checks must pass
- Follows semantic versioning
- Documentation required for changes
          EOT
        }
      ]
    },
    {
      name        = "public-examples"
      description = "Usage examples and tutorials"
      topics      = ["examples", "tutorials", "documentation"]
      # Public repository with simplified protection
      branch_protection = {
        required_status_checks = {
          contexts = ["test"]
        }
      }
    },
    {
      name        = "backend-services"
      description = "Private backend microservices"
      visibility  = "private"
      topics      = ["backend", "microservices", "internal"]
      # Private repo - using alternative process
      extra_files = [
        {
          path = "CONTRIBUTING.md"
          content = <<-EOT
# Development Process

Since this is a private repository using GitHub Free tier:

## Code Review Process
1. Use conventional commit messages
2. Request review via team channel
3. Update changelog
4. Get sign-off from tech lead

## Branch Guidelines
- feature/* for new features
- fix/* for bugfixes
- main is protected by convention

## CI/CD Process
External checks enforce:
- Test coverage
- Style guidelines
- Security scanning
          EOT
        }
      ]
    },
    {
      name        = "deployment-config"
      description = "Private deployment configuration"
      visibility  = "private"
      topics      = ["deployment", "configuration", "internal"]
      # Private repo - using alternative process
      extra_files = [
        {
          path = "SECURITY.md"
          content = <<-EOT
# Security Guidelines

For this private repository:
1. No credentials in code
2. Use environment variables
3. Regular secret rotation
4. Access audit reviews
          EOT
        }
      ]
    }
  ]

  # Development environment configuration
  development_container = {
    base_image = "node:18"
    install_tools = ["git", "npm", "docker"]
    vs_code_extensions = [
      "dbaeumer.vscode-eslint",
      "github.copilot"
    ]
    docker_compose = {
      enabled = true
      services = {
        redis = {
          image = "redis:alpine"
          ports = ["6379:6379"]
        }
      }
    }
  }
}
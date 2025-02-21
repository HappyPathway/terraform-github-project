terraform {
  backend "gcs" {
    bucket = "hpw-terraform-state"
    prefix = "github-projects/django-app"
  }

  required_providers {
    github = {
      source  = "integrations/github"
    }
  }
}

module "django_project" {
  source = "../../"

  project_name    = "django-app"
  repo_org        = "example-org"
  project_prompt  = "Django web application with development environment configuration"

  base_repository = {
    description = "Django web application project with development environment configuration"
    topics      = ["django", "python", "web-app"]
    # Public by default - all features available
    pages = {
      branch = "gh-pages"
      path   = "/docs"
    }
  }

  repositories = [
    {
      name        = "django-frontend"
      description = "Frontend application"
      # Public by default, branch protection enabled
      topics      = ["django", "frontend"]
      gitignore_template = "Node"
      branch_protection = {
        required_status_checks = {
          contexts = ["npm test", "eslint"]
        }
      }
    },
    {
      name        = "django-api"
      description = "Backend API service"
      topics      = ["django", "api", "backend"]
      gitignore_template = "Python"
      visibility  = "private"  # Example of private repo
      # Branch protection automatically disabled for Free tier
    }
  ]

  # Environment configuration
  environments = {
    "django-api" = [
      {
        name = "development"
        vars = [
          {
            name  = "DJANGO_SETTINGS_MODULE"
            value = "config.settings.development"
          }
        ]
      },
      {
        name = "production"
        deployment_branch_policy = {
          protected_branches = true
        }
        reviewers = {
          teams = ["platform-team"]
        }
        vars = [
          {
            name  = "DJANGO_SETTINGS_MODULE"
            value = "config.settings.production"
          }
        ]
      }
    ]
  }
}
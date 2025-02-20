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

  project_name    = "django-ecommerce"
  repo_org        = "my-org"
  project_prompt  = "This is a Django e-commerce application with backend API and frontend components"

  repositories = [
    {
      name        = "backend-api"
      description = "Django REST API backend"
      topics      = ["django", "python", "rest-api"]
      gitignore_template = "Python"
      prompt      = "Django REST API service handling e-commerce operations"
      has_wiki    = true
      has_issues  = true
      branch_protection = {
        required_status_checks = {
          strict = true
          contexts = ["pytest", "black", "isort", "flake8"]
        }
      }
    },
    {
      name        = "frontend"
      description = "React frontend for e-commerce site"
      topics      = ["react", "typescript", "ecommerce"]
      gitignore_template = "Node"
      prompt      = "React TypeScript frontend for e-commerce platform"
      branch_protection = {
        required_status_checks = {
          contexts = ["npm test", "eslint"]
        }
      }
    },
    {
      name        = "infrastructure"
      description = "Infrastructure as Code for e-commerce platform"
      topics      = ["terraform", "aws", "iac"]
      gitignore_template = "Terraform"
      prompt      = "AWS infrastructure configuration for the e-commerce platform"
      branch_protection = {
        required_status_checks = {
          contexts = ["terraform-fmt", "terraform-validate"]
        }
      }
    }
  ]

  # Base repository settings
  base_repository = {
    description = "Django E-commerce Project"
    topics      = ["project-base", "django", "ecommerce"]
    pages = {
      branch = "gh-pages"
      path   = "/docs"
    }
  }

  # Environment configuration
  environments = {
    "backend-api" = [
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
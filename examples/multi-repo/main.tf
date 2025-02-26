terraform {
  required_providers {
    github = {
      source  = "integrations/github"
      version = "~> 6.0"
    }
  }
}

provider "github" {}

module "github_project" {
  source = "../.."

  # Required variables
  repo_org       = var.repo_org
  project_name   = var.project_name
  project_prompt = var.project_prompt

  # Base repository must be public
  base_repository = {
    visibility  = "public"
    description = "Multi-repository project example showing repository relationships"
    topics      = ["project-base", "terraform", "examples"]
  }

  # Additional repositories demonstrating common patterns
  repositories = [
    {
      name       = "service-api"
      prompt     = "A REST API service that provides core business logic"
      topics     = ["api", "service", "backend"]
      visibility = "public" # Must be public without GitHub Pro
    },
    {
      name       = "service-worker"
      prompt     = "Background worker service for processing async tasks"
      topics     = ["worker", "service", "backend"]
      visibility = "public"
    },
    {
      name       = "frontend"
      prompt     = "Web frontend application that consumes the API service"
      topics     = ["frontend", "web", "react"]
      visibility = "public"
    }
  ]

  # Development environment configuration
  vs_code_workspace = {
    settings = {
      "editor.formatOnSave" : true
    }
    extensions = {
      recommended = [
        "hashicorp.terraform",
        "github.copilot",
        "github.copilot-chat"
      ]
    }
  }
}
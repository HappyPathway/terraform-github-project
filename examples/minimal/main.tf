terraform {
  backend "gcs" {
    bucket = "hpw-terraform-state"
    prefix = "github-projects/minimal"
  }

  required_providers {
    github = {
      source  = "integrations/github"
      version = "~> 6.2"
    }
  }
}

provider "github" {}

module "github_project" {
  source = "../.." # Reference to parent module

  # Required variables
  repo_org       = var.repo_org
  project_name   = var.project_name
  project_prompt = var.project_prompt

  # All repositories must be public without GitHub Pro
  base_repository = {
    visibility = "public"
  }

  # Minimal repository configuration
  repositories = [] # No additional repositories in minimal example
}
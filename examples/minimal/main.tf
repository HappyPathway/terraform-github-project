terraform {
  backend "gcs" {
    bucket = "hpw-terraform-state"
    prefix = "github-projects/minimal"
  }

  required_providers {
    github = {
      source  = "integrations/github"
    }
  }
}

module "github_project" {
  source = "../../"

  # Required parameters
  project_name    = "my-project"
  repo_org        = "HappyPathway"
  project_prompt  = "This is the main project prompt that will be used across repos"

  # Example repositories showing both public and private configs
  repositories = [
    {
      name        = "service-a"
      prompt      = "Service A specific prompt"
      # Public by default, branch protection enabled
    },
    {
      name        = "service-b"
      visibility  = "private"
      prompt      = "Service B specific prompt"
      # Private repo will automatically disable branch protection for Free tier
    }
  ]

  # Base repository configuration - will be public by default
  base_repository = {
    description = "Main project repository"
  }
}
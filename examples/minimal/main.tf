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
  
  # Minimal repository configuration with public visibility
  repositories = [
    {
      name       = "service-a"
      prompt     = "Service A specific prompt"
      visibility = "public"  # Make repository public
      github_is_private = false
      enforce_prs = false
    }
  ]
  base_repository = {
    name        = "my-project"
    description = "Main project repository"
    visibility  = "public"
  }
}
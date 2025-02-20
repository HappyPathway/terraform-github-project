module "github_project" {
  source = "../../"

  # Required parameters
  project_name    = "my-project"
  repo_org        = "my-org"
  project_prompt  = "This is the main project prompt that will be used across repos"

  # Minimal repository configuration
  repositories = [
    {
      name   = "service-a"
      prompt = "Service A specific prompt"
    }
  ]

  # Base repository configuration - all settings use defaults
  base_repository = {}
}
module "django_project" {
  source = "../../"

  project_name    = "django-app"
  repo_org        = "example-org"
  project_prompt  = "Django web application with development environment configuration"

  base_repository = {
    description = "Django web application project with development environment configuration"
    topics      = ["django", "python", "web-app"]
    # Public by default - all features available
  }

  repositories = [
    {
      name        = "django-frontend"
      description = "Frontend application"
      # Public by default, branch protection enabled
      topics      = ["django", "frontend"]
    },
    {
      name        = "django-api"
      description = "Backend API service"
      visibility  = "private"  # Example of private repo
      topics      = ["django", "api", "backend"]
      # Branch protection automatically disabled for Free tier
    }
  ]
}
module "acme_shop_project" {
  source = "../../"

  project_name = "acme-shop"
  project_prompt = file("${path.module}/README.md")
  enforce_prs = false  # Disable PR requirements for all repositories by default

  repositories = [
    {
      name = "acme-shop-frontend"
      force_name = true
      repo_org = "HappyPathway"
      github_repo_description = "Frontend React application for ACME Shop"
      github_repo_topics = ["react", "typescript", "frontend", "vite"]
      github_has_issues = true
      github_is_private = false
      prompt = file("${path.module}/frontend-README.md")
    },
    {
      name = "acme-shop-api"
      force_name = true
      repo_org = "HappyPathway"
      github_repo_description = "Backend API for ACME Shop"
      github_repo_topics = ["nodejs", "express", "typescript", "api"]
      github_has_issues = true
      github_is_private = false
      prompt = file("${path.module}/api-README.md")
    },
    {
      name = "acme-shop-db"
      force_name = true
      repo_org = "HappyPathway"
      github_repo_description = "Database schemas and migrations for ACME Shop"
      github_repo_topics = ["postgresql", "database", "migrations"]
      github_has_issues = true
      github_is_private = false
      enforce_prs = true  # Override: Enable PR requirements for the database repository
      prompt = file("${path.module}/db-README.md")
    }
  ]

  # Optional: Additional workspace files
  workspace_files = [
    {
      name = "docs"
      path = "./docs"
    }
  ]
}
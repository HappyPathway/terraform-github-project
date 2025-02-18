module "acme_shop_project" {
  source = "../../"

  project_name = "acme-shop"
  project_prompt = file("${path.module}/README.md")

  repositories = [
    {
      name = "acme-shop-frontend"
      github_repo_description = "Frontend React application for ACME Shop"
      github_repo_topics = ["react", "typescript", "frontend", "vite"]
      github_has_issues = true
      prompt = file("${path.module}/frontend-README.md")
    },
    {
      name = "acme-shop-api"
      github_repo_description = "Backend API for ACME Shop"
      github_repo_topics = ["nodejs", "express", "typescript", "api"]
      github_has_issues = true
      prompt = file("${path.module}/api-README.md")
    },
    {
      name = "acme-shop-db"
      github_repo_description = "Database schemas and migrations for ACME Shop"
      github_repo_topics = ["postgresql", "database", "migrations"]
      github_has_issues = true
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
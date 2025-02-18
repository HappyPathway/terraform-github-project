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
      github_repo_description = "ALB Frontend for ACME Shop"
      github_repo_topics = ["terraform"]
      github_has_issues = true
      github_is_private = false
      prompt = file("${path.module}/frontend-README.md")
    },
    {
      name = "acme-shop-api"
      force_name = true
      repo_org = "HappyPathway"
      github_repo_description = "Backend API for ACME Shop"
      github_repo_topics = ["ansible"]
      github_has_issues = true
      github_is_private = false
      prompt = file("${path.module}/api-README.md")
    },
    {
      name = "acme-shop-db"
      force_name = true
      repo_org = "HappyPathway"
      github_repo_description = "Database migration scripts and configuration for ACME Shop"
      github_repo_topics = ["flask", "database", "migrations"]
      github_has_issues = true
      github_is_private = false
      enforce_prs = true  # Override: Enable PR requirements for the database repository
      prompt = file("${path.module}/db-README.md")
      github_auto_init = true
      github_allow_merge_commit = true
    }
  ]
}
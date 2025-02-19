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

module "example" {
  source = "../../"

  project_name = "multi-tier-webapp"
  project_prompt = "Multi-tier web application with frontend, API, and database components."
  repo_org = "MyOrganization"

  repositories = [
    {
      name = "frontend"
      prompt = "React-based frontend application"
      create_repo = true  # Create a new repository
      github_repo_description = "Frontend web application"
      github_repo_topics = ["frontend", "react", "typescript"]
      github_has_issues = true
      vulnerability_alerts = true
    },
    {
      name = "backend-api"
      prompt = "Node.js REST API service"
      create_repo = false  # Manage an existing repository
      github_repo_description = "Backend API service"
      github_repo_topics = ["backend", "node", "api"]
      github_has_issues = true
      enforce_prs = true
      github_required_approving_review_count = 2
    },
    {
      name = "database"
      prompt = "Database schema and migrations"
      create_repo = false  # Manage an existing repository
      github_repo_description = "Database management"
      github_repo_topics = ["database", "postgresql", "migrations"]
      security_and_analysis = {
        secret_scanning = {
          status = "enabled"
        }
        secret_scanning_push_protection = {
          status = "enabled"
        }
      }
    }
  ]

  # Enable pull request reviews by default
  enforce_prs = true
}
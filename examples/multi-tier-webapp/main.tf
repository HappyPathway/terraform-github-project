module "acme_shop_project" {
  source = "../../"
  project_name = "acme-shop"
  project_prompt = file("${path.module}/README.md")
  repo_org = "HappyPathway"
  
  base_repository = {
    name = "acme-shop"
    description = "ACME Shop Project"
    visibility = "public"
    has_issues = true
    has_wiki = true
    has_projects = true
    enable_branch_protection = false  # Initially disable protection
    enforce_prs = false  # Initially disable PR requirements
    branch_protection = {
      enforce_admins = true
      required_linear_history = true
      require_conversation_resolution = true
      required_approving_review_count = 1
      dismiss_stale_reviews = true
      require_code_owner_reviews = true
    }
  }

  repositories = [
    {
      name = "acme-shop-frontend"
      force_name = true
      repo_org = "HappyPathway"
      github_repo_description = "ALB Frontend for ACME Shop"
      github_repo_topics = ["terraform"]
      github_has_issues = true
      github_is_private = false
      enforce_prs = false  # Don't enforce PRs until files are in place
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
      enforce_prs = false
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
      enforce_prs = false  # Initially disable, can be enabled after files are in place
      prompt = file("${path.module}/db-README.md")
      github_auto_init = true
      github_allow_merge_commit = true
    }
  ]
}
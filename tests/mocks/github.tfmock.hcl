mock_resource "github_repository" {
  defaults = {
    node_id = "R_1234567890"
    private = false
    visibility = "public"
    has_issues = true
    has_discussions = false
    has_projects = true
    has_wiki = true
    is_template = false
    allow_merge_commit = false
    allow_squash_merge = true
    allow_rebase_merge = false
    allow_auto_merge = false
    delete_branch_on_merge = true
    archived = false
    archive_on_destroy = true
    vulnerability_alerts = true
    topics = []
  }
}

mock_resource "github_branch_protection" {
  defaults = {
    pattern = "main"
    required_status_checks = {
      strict = true
      contexts = []
    }
    required_pull_request_reviews = {
      dismiss_stale_reviews = true
      require_code_owner_reviews = true
      required_approving_review_count = 1
    }
    enforce_admins = true
    allows_deletions = false
    allows_force_pushes = false
  }
}

mock_resource "github_repository_file" {
  defaults = {
    commit_message = "Managed by Terraform"
    commit_author = "Terraform"
    commit_email = "terraform@example.com"
    overwrite_on_create = true
  }
}
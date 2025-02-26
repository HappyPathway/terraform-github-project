mock_provider "github" {
  source = "./tests/mocks"
  
  # Mock response for repository_files module
  mock_resource "github_repository_file" {
    defaults = {
      sha = "mock-sha-${timestamp()}"
      commit_sha = "mock-commit-sha-${timestamp()}"
      commit_author = "GitHub Copilot"
      commit_email = "copilot@github.com"
    }
  }

  # Enforce GitHub Free limitations
  mock_data "github_repository" {
    defaults = {
      visibility = "public"  # Force public for branch protection to work
      has_issues = true
      has_projects = true
      has_wiki = true
      allow_merge_commit = true
      allow_squash_merge = true
      allow_rebase_merge = true
      delete_branch_on_merge = false
      allow_auto_merge = false
      allow_update_branch = true
    }
  }
}
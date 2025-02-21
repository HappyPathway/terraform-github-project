mock_resource "github_repository" {
  defaults = {
    name = "test-repo"
    description = "Test repository"
    visibility = "public"
    has_issues = true
    has_wiki = false
    has_projects = true
    has_downloads = true
    allow_merge_commit = true
    allow_squash_merge = true
    allow_rebase_merge = true
    delete_branch_on_merge = false
    auto_init = true
    archived = false
    archive_on_destroy = true
    vulnerability_alerts = true
    topics = []
    template = []
    pages = []
    security_and_analysis = []
  }
}

mock_resource "github_branch_default" {
  defaults = {
    repository = "test-repo"
    branch = "main"
  }
}

mock_resource "github_repository_file" {
  defaults = {
    repository = "test-repo"
    branch = "main"
    commit_message = "Initial commit"
    commit_author = "GitHub Actions"
    commit_email = "actions@github.com"
    overwrite_on_create = true
    content = ""
  }
}

mock_resource "github_repository_files" {
  defaults = {
    repository = "test-repo"
    branch = "main"
    commit_message = "Initial commit"
    commit_author = "GitHub Actions"
    commit_email = "actions@github.com"
    files = {
      "README.md" = {
        content = "# Test Repository\n## Overview\n## Prerequisites\n## Getting Started\n## Development\n## Deployment"
      }
      "CONTRIBUTING.md" = {
        content = "# Contributing Guide\n## Code Style\n## Pull Request Process"
      }
      ".github/CODEOWNERS" = {
        content = "* @test-org/maintainers"
      }
      ".github/pull_request_template.md" = {
        content = "## Description\n\n## Changes"
      }
      "docs/.gitkeep" = {
        content = ""
      }
      "scripts/.gitkeep" = {
        content = ""
      }
      ".github/workflows/.gitkeep" = {
        content = ""
      }
    }
  }
}

mock_resource "github_repository_environment" {
  defaults = {
    environment = "dev"
    repository = "test-repo"
    reviewers = []
    deployment_branch_policy = []
  }
}

mock_data "github_repository" {
  defaults = {
    name = "test-repo"
    full_name = "test-org/test-repo"
    description = "Test repository"
    visibility = "public"
    has_issues = true
    has_wiki = false
    has_projects = true
    has_downloads = true
    default_branch = "main"
    archived = false
    topics = []
    allow_merge_commit = true
    allow_squash_merge = true
    allow_rebase_merge = true
    delete_branch_on_merge = false
  }
}
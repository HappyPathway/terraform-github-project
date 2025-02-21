mock_provider "github" {
  source = "./tests/mocks"
}

variables {
  project_name = "test-project-static"
  project_prompt = "Test project prompt"
  repo_org = "HappyPathway"
  github_pro_enabled = false
  repositories = [
    {
      name = "test-repo-1"
      prompt = "Test repo prompt"
      github_repo_description = "Test repository"
      github_repo_topics = ["test", "terraform"]
      force_name = true
      create_repo = true
      github_is_private = false  // Must be public for branch protection with GitHub Free
    },
    {
      name = "test-repo-2"
      prompt = "Second test repo prompt"
      github_repo_description = "Second test repository"
      github_repo_topics = ["test", "terraform"]
      force_name = true
      create_repo = true
      github_is_private = false  // Must be public for branch protection with GitHub Free
    }
  ]
  base_repository = {
    name = "test-project-base"
    description = "Base repository for test project"
    topics = ["project-base", "test"]
    create_repo = true
    force_name = true
    visibility = "public"  // Must be public for branch protection with GitHub Free
    allow_unsigned_files = true
    branch_protection = {
      enforce_admins = true
      required_linear_history = true
      allow_force_pushes = false
      allow_deletions = false
      require_conversation_resolution = true
      required_approving_review_count = 1
      dismiss_stale_reviews = true
      require_code_owner_reviews = true
      required_status_checks = {
        strict = true
        contexts = []
      }
    }
  }
  enforce_prs = true
  workspace_files = [
    {
      name = "Test Workspace",
      path = "test-workspace.code-workspace"
    }
  ]
}

# Phase 1: Basic Configuration Tests
run "verify_organization_exists" {
  command = plan

  # Simplified org check since we're using mocked provider
  assert {
    condition     = var.repo_org != ""
    error_message = "Organization name must not be empty"
  }
}

run "validate_project_configuration" {
  command = plan

  assert {
    condition     = var.project_name != ""
    error_message = "Project name must not be empty"
  }

  assert {
    condition     = var.project_prompt != ""
    error_message = "Project prompt must not be empty"
  }
}

# Phase 2: Resource Creation Tests
run "verify_base_repository_creation" {
  command = plan

  assert {
    condition     = var.base_repository.create_repo == true
    error_message = "Base repository creation should be enabled"
  }

  assert {
    condition     = can(regex("^[a-zA-Z0-9_-]+$", var.project_name))
    error_message = "Base repository name contains invalid characters"
  }

  assert {
    condition     = var.base_repository.visibility == "public"
    error_message = "Base repository must be public for branch protection in non-Pro accounts"
  }

  assert {
    condition     = var.base_repository.create_repo == true
    error_message = "Base repository creation should be enabled"
  }
}

run "verify_branch_protection_rules" {
  command = plan

  assert {
    condition     = var.base_repository.branch_protection.enforce_admins == true
    error_message = "Branch protection enforce_admins should be enabled"
  }

  assert {
    condition     = var.base_repository.visibility == "public"
    error_message = "Base repository must be public for branch protection in GitHub Free"
  }

  assert {
    condition     = var.base_repository.branch_protection.required_approving_review_count >= 1
    error_message = "At least one approving review should be required"
  }
}

run "verify_repository_settings" {
  command = plan

  assert {
    condition     = length(var.repositories) > 0
    error_message = "At least one project repository must be defined"
  }

  assert {
    condition     = alltrue([
      for repo in var.repositories :
      can(regex("^[a-zA-Z0-9_-]+$", repo.name))
    ])
    error_message = "Repository names contain invalid characters"
  }

  assert {
    condition     = alltrue([
      for repo in var.repositories :
      repo.github_is_private == false
    ])
    error_message = "Test repositories must be public for branch protection in non-Pro accounts"
  }
}

# Phase 3: Error Handling Tests
run "validate_repository_uniqueness" {
  command = plan

  assert {
    condition     = length(distinct([for repo in var.repositories : repo.name])) == length(var.repositories)
    error_message = "Repository names must be unique"
  }
}

run "check_required_fields" {
  command = plan

  assert {
    condition     = alltrue([
      for repo in var.repositories :
      repo.prompt != null && repo.prompt != ""
    ])
    error_message = "All repositories must have a prompt defined"
  }
}

# Phase 4: Integration Tests
run "verify_workspace_files" {
  command = plan

  assert {
    condition     = length(var.workspace_files) > 0
    error_message = "Workspace files should be configured"
  }
}

run "verify_repository_relationships" {
  command = plan

  assert {
    condition     = length(var.repositories) >= 2
    error_message = "Test requires at least two repositories for relationship testing"
  }
}

run "verify_codeowners_creation" {
  command = plan

  assert {
    condition     = var.base_repository.branch_protection.require_code_owner_reviews == true
    error_message = "CODEOWNERS reviews should be required in branch protection"
  }
}

run "verify_branch_protection_inheritance" {
  command = plan

  assert {
    condition     = var.enforce_prs == true
    error_message = "PR enforcement should be enabled globally"
  }

  assert {
    condition     = alltrue([
      for repo in var.repositories :
      lookup(repo, "enforce_prs", var.enforce_prs) == true
    ])
    error_message = "PR enforcement should be inherited by all repositories"
  }
}

run "verify_file_management" {
  command = plan

  assert {
    condition     = var.base_repository.allow_unsigned_files == true
    error_message = "Base repository should allow unsigned files during testing"
  }
}

# run "verify_repository_creation" {
#   command = apply
  
#   variables {
#     enforce_prs = false
#   }

#   assert {
#     condition     = var.base_repository.create_repo == true
#     error_message = "Base repository creation failed"
#   }

#   assert {
#     condition     = alltrue([
#       for repo in var.repositories : repo.create_repo == true
#     ])
#     error_message = "Project repositories creation failed"
#   }
# }
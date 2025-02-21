locals {
  # GitHub Free tier validation
  validate_github_free = {
    private_repos_with_protection = [
      for repo in var.repositories :
      repo.name if try(repo.visibility, "public") == "private" && try(repo.enable_branch_protection, true)
    ]
  }

  # Validation messages
  validation_errors = [
    length(local.validate_github_free.private_repos_with_protection) > 0 ?
    "GitHub Free tier does not support branch protection on private repositories: ${join(", ", local.validate_github_free.private_repos_with_protection)}. Either make repositories public or upgrade to GitHub Pro." : "",
  ]
}

# Add validation check
resource "null_resource" "github_free_validation" {
  count = length(compact(local.validation_errors)) > 0 ? "ERROR" : 0

  lifecycle {
    precondition {
      condition     = length(compact(local.validation_errors)) == 0
      error_message = join("\n", compact(local.validation_errors))
    }
  }
}
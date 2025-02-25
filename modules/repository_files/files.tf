locals {
  should_manage_files = var.mkfiles

  # Ensure consistent paths for special files
  standardized_files = [
    for file in var.files : {
      name    = file.name
      content = file.content
    }
  ]

  # Create a map of paths to count of occurrences
  path_counts = {
    for path in local.standardized_files[*].name :
    path => length([for f in local.standardized_files : f if f.name == path])
  }

  # Find paths that appear more than once
  duplicate_paths = {
    for path, count in local.path_counts :
    path => count if count > 1
  }
}

# Manage repository files
resource "github_repository_file" "files" {
  for_each = var.mkfiles ? {
    for file in local.standardized_files : file.name => file
  } : {}
  
  repository          = var.repository
  branch              = var.branch
  file                = each.value.name
  content             = each.value.content
  commit_message      = "Adding ${each.value.name}"
  commit_author       = try(var.commit.author, null)
  commit_email        = try(var.commit.email, null)
  overwrite_on_create = true

  lifecycle {
    precondition {
      condition     = length(local.duplicate_paths) == 0
      error_message = "Duplicate file paths detected: ${jsonencode(local.duplicate_paths)}"
    }
  }
}
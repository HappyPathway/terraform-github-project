# Manage repository files
resource "github_repository_file" "files" {
  for_each = {
    for file in var.files : file.name => file
  }

  repository          = var.repository
  branch              = var.branch
  file                = each.key
  content             = each.value.content
  commit_message      = "Adding ${each.key}"
  overwrite_on_create = true

  lifecycle {
    ignore_changes = [
      branch
    ]
  }
}
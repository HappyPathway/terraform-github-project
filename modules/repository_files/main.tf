resource "github_repository_file" "files" {
  for_each = var.files

  repository          = var.repository
  branch             = var.branch
  file               = each.value.name
  content            = each.value.content
  commit_message     = "Adding ${each.key.name}"
  overwrite_on_create = var.overwrite_on_create

  lifecycle {
    ignore_changes = [
      branch
    ]
  }
}
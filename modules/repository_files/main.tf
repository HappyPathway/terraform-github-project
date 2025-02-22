resource "github_repository_file" "files" {
  for_each = { for file in var.files : file.name => file.content }

  repository          = var.repository
  branch             = var.branch
  file               = each.key
  content            = each.value
  commit_message     = "Adding ${each.key}"
  overwrite_on_create = var.overwrite_on_create

  lifecycle {
    ignore_changes = [
      branch
    ]
  }
}
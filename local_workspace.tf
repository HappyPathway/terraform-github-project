locals {
  workspace_folders = concat(
    [{
      name = var.project_name,
      path = "."
    }],
    [for repo in var.repositories : {
      name = repo.name,
      path = "../${repo.name}"
    }],
    coalesce(var.workspace_files, [])
  )
}
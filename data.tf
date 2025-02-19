// ...existing data blocks...

data "github_repository" "existing_lookup" {
  for_each = { for repo in var.repositories : repo.name => repo if repo.create_repo == false }
  name     = each.value.name
  full_name = var.repo_org != null ? "${each.value.repo_org}/${each.value.name}" : (var.repo_org != null ? "${var.repo_org}/${each.value.name}" : each.value.name)
}
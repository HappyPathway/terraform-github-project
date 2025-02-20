data "github_organization" "org" {
  name = var.repo_org
}

// ...existing data blocks...

data "github_repository" "existing_lookup" {
  for_each  = { for repo in var.repositories : repo.name => repo if repo.create_repo == false }
  full_name = "${var.repo_org}/${each.value.name}"
}
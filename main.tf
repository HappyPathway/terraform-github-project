# Repositories data source
data "github_repository" "existing_repos" {
  for_each  = { for repo in var.repositories : repo.name => repo if try(repo.create_repo, true) == false }
  full_name = "${coalesce(each.value.repo_org, var.repo_org)}/${each.key}"
}
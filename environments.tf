// Repository environments configuration
module "repository_environments" {
  for_each = { for repo in var.repositories : repo.name => repo }
  source   = "../terraform-github-repo"
  name = each.key
  # Pass only the environment configurations for this specific repository
  environments = [
    for env in coalesce(each.value.environments, []) : {
      name = env.name
      reviewers = {
        teams = coalesce(env.reviewers.teams, [])
        users = coalesce(env.reviewers.users, [])
      }
      deployment_branch_policy = {
        protected_branches     = coalesce(env.deployment_branch_policy.protected_branches, true)
        custom_branch_policies = coalesce(env.deployment_branch_policy.custom_branch_policies, false)
      }
      secrets = coalesce(env.secrets, [])
      vars    = coalesce(env.vars, [])
    }
  ]

  depends_on = [module.project_repos]
}
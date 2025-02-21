locals {
  network_tools = distinct(flatten([
    for repo in var.repositories :
    [for topic in coalesce(repo.github_repo_topics, []) :
     topic if can(regex("^(network|firewall|waf|cdn|lb)", topic))]
  ]))

  zero_trust = anytrue([
    for repo in var.repositories :
    contains(coalesce(repo.github_repo_topics, []), "zero-trust") ||
    contains(coalesce(repo.github_repo_topics, []), "zero-trust-network")
  ])

  service_mesh = anytrue([
    for repo in var.repositories :
    contains(coalesce(repo.github_repo_topics, []), "service-mesh") ||
    contains(coalesce(repo.github_repo_topics, []), "istio") ||
    contains(coalesce(repo.github_repo_topics, []), "linkerd")
  ])

  network_policies = distinct(flatten([
    for repo in var.repositories :
    [for topic in coalesce(repo.github_repo_topics, []) :
     topic if can(regex("^(network-policy|security-group|acl)", topic))]
  ]))
}
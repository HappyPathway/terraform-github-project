locals {
  network_security = {
    network_tools = distinct(flatten([
      for repo in var.repositories : [
        for topic in coalesce(repo.github_repo_topics, []) :
        lower(topic) if contains([
          "istio", "linkerd", "cilium", "calico",
          "consul", "envoy", "nginx", "traefik"
        ], lower(topic))
      ]
    ]))
    zero_trust = anytrue([
      for repo in var.repositories :
      contains(coalesce(repo.github_repo_topics, []), "zero-trust") ||
      contains(coalesce(repo.github_repo_topics, []), "beyondcorp")
    ])
    service_mesh = anytrue([
      for repo in var.repositories :
      contains(coalesce(repo.github_repo_topics, []), "istio") ||
      contains(coalesce(repo.github_repo_topics, []), "linkerd") ||
      contains(coalesce(repo.github_repo_topics, []), "consul")
    ])
    network_policies = distinct(flatten([
      for repo in var.repositories : [
        for topic in coalesce(repo.github_repo_topics, []) :
        lower(topic) if contains([
          "network-policy", "security-groups", "nacl",
          "firewall", "waf", "ddos-protection"
        ], lower(topic))
      ]
    ]))
  }
}
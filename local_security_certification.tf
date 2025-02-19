locals {
  security_certification = {
    frameworks = local.security_frameworks
    requires_audit = anytrue([
      for repo in var.repositories :
      contains(coalesce(repo.github_repo_topics, []), "compliance") ||
      contains(coalesce(repo.github_repo_topics, []), "audit") ||
      length(local.security_frameworks) > 0
    ])
    security_controls = distinct(flatten([
      for repo in var.repositories : [
        for topic in coalesce(repo.github_repo_topics, []) :
        lower(topic) if contains([
          "rbac", "iam", "mfa", "zero-trust",
          "encryption-at-rest", "encryption-in-transit",
          "waf", "ddos-protection", "ids", "ips"
        ], lower(topic))
      ]
    ]))
  }
}
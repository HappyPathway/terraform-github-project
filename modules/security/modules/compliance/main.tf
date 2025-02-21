locals {
  data_protection = {
    encryption_required = anytrue([
      for repo in var.repositories :
      contains(coalesce(repo.github_repo_topics, []), "encryption") ||
      contains(coalesce(repo.github_repo_topics, []), "kms")
    ])
    backup_configured = anytrue([
      for repo in var.repositories :
      contains(coalesce(repo.github_repo_topics, []), "backup") ||
      contains(coalesce(repo.github_repo_topics, []), "disaster-recovery")
    ])
    audit_logging = anytrue([
      for repo in var.repositories :
      contains(coalesce(repo.github_repo_topics, []), "audit") ||
      contains(coalesce(repo.github_repo_topics, []), "logging")
    ])
  }

  compliance_frameworks = var.security_frameworks

  requires_audit = anytrue([
    for repo in var.repositories :
    contains(coalesce(repo.github_repo_topics, []), "compliance") ||
    contains(coalesce(repo.github_repo_topics, []), "audit") ||
    length(var.security_frameworks) > 0
  ])

  security_controls = distinct(flatten([
    for repo in var.repositories :
    [for topic in coalesce(repo.github_repo_topics, []) :
     topic if can(regex("^(security-control|control|compliance-control)", topic))]
  ]))
}
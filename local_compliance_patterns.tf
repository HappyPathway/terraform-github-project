locals {
  compliance_patterns = {
    data_protection = {
      encryption_required = anytrue([
        for repo in var.repositories :
        contains(coalesce(repo.github_repo_topics, []), "encryption") ||
        contains(coalesce(repo.github_repo_topics, []), "kms") ||
        local.security_scanning
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
    compliance_frameworks = local.security_frameworks
    requires_audit = anytrue([
      for repo in var.repositories :
      contains(coalesce(repo.github_repo_topics, []), "compliance") ||
      contains(coalesce(repo.github_repo_topics, []), "audit") ||
      length(local.security_frameworks) > 0
    ])
    monitoring_required = anytrue([
      for repo in var.repositories :
      contains(coalesce(repo.github_repo_topics, []), "monitoring") ||
      contains(coalesce(repo.github_repo_topics, []), "observability")
    ])
  }
}
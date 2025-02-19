locals {
  security_scanning = anytrue([
    for repo in var.repositories : 
    try(repo.security_and_analysis.secret_scanning.status == "enabled" ||
        repo.security_and_analysis.secret_scanning_push_protection.status == "enabled", false)
  ])

  security_frameworks = distinct(flatten([
    for repo in var.repositories : [
      for topic in coalesce(repo.github_repo_topics, []) :
      upper(topic) if contains([
        "soc2",
        "iso27001",
        "fedramp",
        "pci-dss",
        "hipaa",
        "gdpr",
        "ccpa",
        "nist"
      ], lower(topic))
    ]
  ]))
}
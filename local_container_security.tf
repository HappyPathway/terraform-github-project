locals {
  container_security = {
    scanning_tools = distinct(flatten([
      for repo in var.repositories : [
        for topic in coalesce(repo.github_repo_topics, []) :
        lower(topic) if contains([
          "trivy", "clair", "aqua", "snyk-container",
          "docker-scan", "anchore", "grype"
        ], lower(topic))
      ]
    ]))
    runtime_security = distinct(flatten([
      for repo in var.repositories : [
        for topic in coalesce(repo.github_repo_topics, []) :
        lower(topic) if contains([
          "falco", "apparmor", "seccomp", "gatekeeper",
          "kyverno", "runtime-security"
        ], lower(topic))
      ]
    ]))
    registry_security = distinct(flatten([
      for repo in var.repositories : [
        for topic in coalesce(repo.github_repo_topics, []) :
        lower(topic) if contains([
          "harbor", "docker-trusted-registry", "cosign",
          "container-signing", "notary"
        ], lower(topic))
      ]
    ]))
    uses_distroless = anytrue([
      for repo in var.repositories :
      contains(coalesce(repo.github_repo_topics, []), "distroless")
    ])
  }
}
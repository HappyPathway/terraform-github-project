locals {
  container_scanning_required = anytrue([
    for repo in var.repositories :
    contains(coalesce(repo.github_repo_topics, []), "container") ||
    contains(coalesce(repo.github_repo_topics, []), "docker")
  ])

  registry_security_required = anytrue([
    for repo in var.repositories :
    contains(coalesce(repo.github_repo_topics, []), "container-registry") ||
    contains(coalesce(repo.github_repo_topics, []), "registry-security")
  ])

  runtime_security_required = anytrue([
    for repo in var.repositories :
    contains(coalesce(repo.github_repo_topics, []), "runtime-security") ||
    contains(coalesce(repo.github_repo_topics, []), "container-runtime")
  ])

  effective_container_config = {
    scanning_tools    = local.container_scanning_required ? var.container_security_config.scanning_tools : []
    runtime_security  = local.runtime_security_required ? var.container_security_config.runtime_security : []
    registry_security = local.registry_security_required ? var.container_security_config.registry_security : []
    uses_distroless  = var.container_security_config.uses_distroless
  }
}
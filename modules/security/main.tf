locals {
  security_scanning = var.enable_security_scanning

  container_security = {
    scanning_tools    = var.container_security_config.scanning_tools
    runtime_security  = var.container_security_config.runtime_security
    registry_security = var.container_security_config.registry_security
    uses_distroless  = var.container_security_config.uses_distroless
  }

  security_scanning_enabled = anytrue([
    for repo in var.repositories :
    contains(coalesce(repo.github_repo_topics, []), "security-scanning") ||
    contains(coalesce(repo.github_repo_topics, []), "vulnerability-scanning")
  ])

  security_frameworks = var.security_frameworks
}

module "container" {
  source = "./modules/container"
  
  repositories = var.repositories
  container_security_config = local.container_security
}

module "network" {
  source = "./modules/network"
  
  repositories = var.repositories
}

module "compliance" {
  source = "./modules/compliance"
  
  repositories = var.repositories
  security_frameworks = local.security_frameworks
}
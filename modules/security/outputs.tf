output "security_configuration" {
  description = "Security configuration for the repositories"
  value = {
    scanning_enabled = local.security_scanning
    frameworks       = local.security_frameworks
  }
}

output "container_security_config" {
  description = "Container security configuration"
  value       = local.container_security_config
}

output "network_security_config" {
  description = "Network security configuration"
  value       = local.network_security_config
}

output "compliance_config" {
  description = "Compliance configuration"
  value       = local.compliance_config
}

output "files" {
  description = "List of files to be created by this module"
  value = [
    {
      name = ".github/prompts/security-requirements.prompt.md"
      content = templatefile("${path.module}/templates/security-requirements.prompt.md", {
        repository_name = var.repositories[0].name
        topics          = try(var.repositories[0].github_repo_topics, [])
        frameworks      = var.security_frameworks
      })
    },
    {
      name = ".github/security/SECURITY.md"
      content = templatefile("${path.module}/templates/SECURITY.md", {
        repository_name = var.repositories[0].name
        frameworks      = var.security_frameworks
      })
    }
  ]
}
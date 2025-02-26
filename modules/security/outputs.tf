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
  description = "Map of files to be created in repositories"
  value = length(var.repositories) > 0 ? {
    ".github/workflows/security.yml" = {
      content = templatefile("${path.module}/templates/security.yml.tpl", {
        repository_name = var.repositories[0].name
        branch          = "main"
      })
    }
    ".github/workflows/container-security.yml" = {
      content = templatefile("${path.module}/templates/container-security.yml.tpl", {
        repository_name = var.repositories[0].name
        branch          = "main"
      })
    }
  } : {}
}
output "security_configuration" {
  description = "Security configuration for the repositories"
  value = {
    scanning_enabled = local.security_scanning
    frameworks      = local.security_frameworks
  }
}

output "container_security_config" {
  description = "Container security configuration"
  value = module.container.effective_container_config
}

output "network_security_config" {
  description = "Network security configuration"
  value = module.network.network_security_config
}

output "compliance_config" {
  description = "Compliance configuration"
  value = module.compliance.compliance_config
}
output "container_security_config" {
  description = "Effective container security configuration"
  value       = local.effective_container_config
}

output "container_scanning_required" {
  description = "Whether container scanning is required based on repository topics"
  value       = local.container_scanning_required
}

output "registry_security_required" {
  description = "Whether registry security features are required based on repository topics"
  value       = local.registry_security_required
}

output "runtime_security_required" {
  description = "Whether runtime security features are required based on repository topics"
  value       = local.runtime_security_required
}
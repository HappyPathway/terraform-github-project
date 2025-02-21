output "compliance_config" {
  description = "Compliance configuration derived from repository analysis"
  value = {
    data_protection = local.data_protection
    compliance_frameworks = local.compliance_frameworks
    requires_audit = local.requires_audit
    security_controls = local.security_controls
  }
}

output "encryption_required" {
  description = "Whether encryption is required based on repository topics"
  value       = local.data_protection.encryption_required
}

output "backup_configured" {
  description = "Whether backup is configured based on repository topics"
  value       = local.data_protection.backup_configured
}

output "audit_logging_enabled" {
  description = "Whether audit logging is enabled based on repository topics"
  value       = local.data_protection.audit_logging
}
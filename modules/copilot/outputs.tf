output "copilot_instructions" {
  description = "Generated or provided GitHub Copilot instructions"
  value       = local.copilot_instructions
}

output "detected_languages" {
  description = "Programming languages detected from repository topics"
  value       = local.languages
}

output "detected_frameworks" {
  description = "Frameworks detected from repository topics"
  value       = local.frameworks
}

output "detected_testing_tools" {
  description = "Testing tools detected from repository topics"
  value       = local.testing_tools
}

output "detected_iac_tools" {
  description = "Infrastructure as Code tools detected from repository topics"
  value       = local.iac_tools
}

output "detected_cloud_providers" {
  description = "Cloud providers detected from repository topics"
  value       = local.cloud_providers
}

output "detected_security_tools" {
  description = "Security tools detected from repository topics"
  value       = local.security_tools
}

output "generated_instructions" {
  description = "Generated GitHub Copilot instructions based on repository analysis"
  value       = local.generated_copilot_instructions
}

output "repository_files" {
  description = "Map of repository file contents to be created"
  value       = local.repository_files
}
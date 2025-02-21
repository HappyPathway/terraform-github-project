output "code_quality_config" {
  description = "Complete code quality configuration derived from repository analysis"
  value       = local.code_quality_config
}

output "detected_linting_tools" {
  description = "Linting tools detected from repository topics"
  value       = local.linting_tools
}

output "detected_formatting_tools" {
  description = "Code formatting tools detected from repository topics"
  value       = local.formatting_tools
}

output "detected_documentation_tools" {
  description = "Documentation tools detected from repository topics"
  value       = local.documentation_tools
}

output "has_type_checking" {
  description = "Whether type checking is enabled based on repository topics"
  value       = local.has_type_checking
}
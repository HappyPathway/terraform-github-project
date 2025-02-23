output "code_quality_config" {
  description = "Complete quality configuration"
  value       = local.code_quality_config
}

output "detected_linting_tools" {
  description = "Linting tools detected from repository topics"
  value       = local.detected_linting_tools
}

output "detected_formatting_tools" {
  description = "Code formatting tools detected"
  value       = local.detected_formatting_tools
}

output "detected_documentation_tools" {
  description = "Documentation tools detected"
  value       = local.detected_documentation_tools
}

output "has_type_checking" {
  description = "Whether type checking is enabled"
  value       = local.has_type_checking
}

output "files" {
  description = "List of files to be created by this module"
  value = [
    {
      name = ".github/prompts/quality-standards.prompt.md"
      content = templatefile("${path.module}/templates/quality-standards.prompt.md", {
        repository_name     = var.repositories[0].name
        linting_tools       = local.detected_linting_tools
        formatting_tools    = local.detected_formatting_tools
        documentation_tools = local.detected_documentation_tools
        has_type_checking   = local.has_type_checking
        quality_config      = try(var.quality_config, {})
      })
    }
  ]
}
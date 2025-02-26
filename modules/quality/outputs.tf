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
  description = "Map of files to be created in repositories"
  value = length(var.repositories) > 0 ? {
    ".github/workflows/quality.yml" = {
      content = templatefile("${path.module}/templates/quality.yml.tpl", {
        repository_name    = var.repositories[0].name
        branch             = "main"
        code_quality_tools = try(local.detected_linting_tools, [])
      })
    }
  } : {}
}
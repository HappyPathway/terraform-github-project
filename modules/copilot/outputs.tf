output "copilot_instructions" {
  description = "GitHub Copilot instructions generated for repositories"
  value       = local.copilot_instructions != "" ? local.copilot_instructions : local.generated_copilot_instructions
}

output "detected_languages" {
  description = "Programming languages detected from repository topics"
  value       = local.detected_languages
}

output "detected_frameworks" {
  description = "Frameworks detected from repository topics"
  value       = local.detected_frameworks
}

output "detected_testing_tools" {
  description = "Testing tools detected from repository topics"
  value       = local.detected_testing_tools
}

output "detected_iac_tools" {
  description = "Infrastructure as Code tools detected"
  value       = local.detected_iac_tools
}

output "detected_cloud_providers" {
  description = "Cloud providers detected from repository topics"
  value       = local.detected_cloud_providers
}

output "detected_security_tools" {
  description = "Security tools detected from repository topics"
  value       = local.detected_security_tools
}

output "generated_instructions" {
  description = "Generated GitHub Copilot instructions based on repository analysis"
  value       = local.generated_copilot_instructions
}

output "repository_files" {
  description = "Map of repository file contents to be created"
  value       = local.repository_files
}

output "files" {
  description = "Map of files to be created in repositories"
  value = length(var.repositories) > 0 ? {
    ".vscode/copilot.json" = {
      content = jsonencode({
        instructions    = var.copilot_instructions
        repository_name = var.repositories[0].name
      })
    }
  } : {}
}

output "copilot_files" {
  description = "List of Copilot instruction files and prompts"
  value = {
    instructions_path = ".github/copilot-instructions.md"
    instructions      = local.copilot_instructions != "" ? local.copilot_instructions : local.generated_copilot_instructions
    prompts           = local.repository_files
  }
}
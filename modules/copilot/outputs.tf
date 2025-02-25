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
  description = "List of files to be created by this module"
  value = concat(
    [
      {
        name = ".github/copilot-instructions.md"
        content = templatefile("${path.module}/templates/copilot-instructions.prompt.md", {
          project_name    = var.project_name
          repository_name = var.repositories[0].name
          languages       = local.detected_languages
          frameworks      = local.detected_frameworks
          testing_tools   = local.detected_testing_tools
          iac_tools       = local.detected_iac_tools
          cloud_providers = local.detected_cloud_providers
          security_tools  = local.detected_security_tools
          instructions    = var.copilot_instructions
        })
      }
    ],
    local.files  # Only includes repo-specific prompt files
  )
}

output "copilot_files" {
  description = "List of Copilot instruction files and prompts"
  value = {
    instructions_path = ".github/copilot-instructions.md"
    instructions      = local.copilot_instructions != "" ? local.copilot_instructions : local.generated_copilot_instructions
    prompts           = local.repository_files
  }
}
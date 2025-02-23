output "infrastructure_config" {
  description = "Complete infrastructure configuration derived from repository analysis"
  value       = local.module_config
}

output "detected_iac_tools" {
  description = "IaC tools detected from repository topics"
  value       = local.detected_iac_tools
}

output "detected_cloud_providers" {
  description = "Cloud providers detected from repository topics"
  value       = local.detected_cloud_providers
}

output "has_kubernetes" {
  description = "Whether Kubernetes is used in the repositories"
  value       = local.has_kubernetes
}

output "uses_terraform_modules" {
  description = "Whether Terraform modules are used based on repository topics"
  value       = local.uses_terraform_modules
}

output "module_documentation_tools" {
  description = "Documentation tools detected for infrastructure modules"
  value       = local.module_documentation_tools
}

output "module_testing_frameworks" {
  description = "Testing frameworks detected for infrastructure modules"
  value       = local.module_testing_frameworks
}

output "module_config" {
  description = "Module configuration details"
  value       = local.module_config
}

output "files" {
  description = "List of files to be created by this module"
  value = [
    {
      name = ".github/prompts/infrastructure-guidelines.prompt.md"
      content = templatefile("${path.module}/templates/infrastructure-guidelines.prompt.md", {
        repository_name = var.repositories[0].name
        iac_tools       = local.detected_iac_tools
        cloud_providers = local.detected_cloud_providers
        has_kubernetes  = local.has_kubernetes
        iac_config      = try(var.iac_config, {})
      })
    }
  ]
}
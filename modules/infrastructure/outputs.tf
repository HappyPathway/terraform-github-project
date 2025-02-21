output "infrastructure_config" {
  description = "Complete infrastructure configuration derived from repository analysis"
  value       = local.module_config
}

output "detected_iac_tools" {
  description = "Infrastructure as Code tools detected from repository topics"
  value       = local.iac_tools
}

output "detected_cloud_providers" {
  description = "Cloud providers detected from repository topics"
  value       = local.cloud_providers
}

output "has_kubernetes" {
  description = "Whether Kubernetes is used based on repository topics"
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
  description = "Module configuration including all detected patterns"
  value       = local.module_config
}
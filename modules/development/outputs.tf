output "development_config" {
  description = "Complete development configuration including standards and deployment patterns"
  value       = local.development_config
}

output "detected_languages" {
  description = "Programming languages detected from repository topics"
  value       = module.standards.languages_detected
}

output "detected_frameworks" {
  description = "Frameworks detected from repository topics"
  value       = module.standards.frameworks_detected
}

output "detected_deployment_strategies" {
  description = "Deployment strategies detected from repository topics"
  value       = module.deployment.deployment_strategies_detected
}

output "ci_cd_tools" {
  description = "CI/CD tools detected or configured"
  value       = module.deployment.ci_cd_tools_detected
}

output "standards_config" {
  description = "Development standards configuration"
  value = {
    testing_requirements = local.testing_requirements
    code_quality         = local.code_quality_config
  }
}

output "deployment_config" {
  description = "Deployment configuration"
  value = {
    ci_cd        = local.ci_cd_config
    environments = local.deployment_environments
  }
}
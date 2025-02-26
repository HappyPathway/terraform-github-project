output "development_config" {
  description = "Complete development configuration including standards and deployment patterns"
  value       = local.development_config
}

output "detected_languages" {
  description = "Programming languages detected from repository topics"
  value       = local.detected_languages
}

output "detected_frameworks" {
  description = "Frameworks detected from repository topics"
  value       = local.detected_frameworks
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
  value       = local.standards_config
}

output "deployment_config" {
  description = "Deployment configuration"
  value       = local.deployment_config
}

output "files" {
  description = "Map of files to be created in repositories"
  value = length(var.repositories) > 0 ? {
    ".github/workflows/ci.yml" = {
      content = templatefile("${path.module}/templates/ci.yml.tpl", {
        repository_name = var.repositories[0].name
        branch          = "main"
      })
    }
  } : {}
}
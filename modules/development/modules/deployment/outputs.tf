output "deployment_config" {
  description = "Deployment configuration derived from repository analysis"
  value       = local.deployment_config
}

output "deployment_strategies_detected" {
  description = "List of deployment strategies detected from repository topics"
  value       = local.deployment_strategies
}

output "ci_cd_tools_detected" {
  description = "List of CI/CD tools detected from repository topics"
  value       = local.ci_cd_tools
}

output "uses_gitops" {
  description = "Whether GitOps practices are detected from repository topics"
  value       = local.uses_gitops
}

output "uses_feature_flags" {
  description = "Whether feature flags are used based on repository topics"
  value       = local.feature_flags
}
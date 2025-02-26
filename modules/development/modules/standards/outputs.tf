output "development_standards" {
  description = "Development standards configuration derived from repository analysis"
  value       = local.development_standards
}

output "languages_detected" {
  description = "List of programming languages detected from repository topics"
  value       = local.languages
}

output "frameworks_detected" {
  description = "List of frameworks detected from repository topics"
  value       = local.frameworks
}

output "testing_tools_detected" {
  description = "List of testing tools detected from repository topics"
  value       = local.testing_tools
}
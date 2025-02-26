
output "files" {
  description = "Development environment files to be created"
  value       = local.files
}

output "workspace_config" {
  description = "VS Code workspace configuration"
  value = {
    settings   = local.effective_vscode.settings
    extensions = local.effective_vscode.extensions
    tasks      = local.effective_vscode.tasks
    launch     = local.effective_vscode.launch_configurations
  }
}
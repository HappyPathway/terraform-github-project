output "files" {
  description = "Map of created repository files"
  value       = github_repository_file.files
}

output "file_paths" {
  description = "List of created file paths"
  value       = keys(github_repository_file.files)
}
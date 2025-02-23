output "repository" {
  description = "Repository name where files were created"
  value       = var.repository
}

output "files" {
  description = "List of files managed in the repository"
  value = {
    for name, file in github_repository_file.files : name => {
      path    = file.file
      content = file.content
    }
  }
}

output "file_paths" {
  description = "List of created file paths"
  value       = keys(github_repository_file.files)
}
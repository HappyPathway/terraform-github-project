locals {
  initialization_template_vars = {
    project_name = var.project_name
    repo_org     = var.repo_org
    base_repo    = try(var.repositories[0].name, "")
    repositories = [for repo in var.repositories : repo.name]
    custom_script = try(var.initialization_script.content, "")
  }

  # Generate workspace file content
  workspace_content = templatefile(
    "${path.module}/templates/workspace.json.tpl",
    {
      folders = local.workspace_folders
      recommended_extensions = local.recommended_extensions
    }
  )

  # Generate initialization script content
  init_script_content = templatefile(
    "${path.module}/templates/init.sh.tpl",
    local.initialization_template_vars
  )

  # Files to be created in the base repository
  repo_files = {
    "${var.project_name}.code-workspace" = {
      content = local.workspace_content
      description = "VS Code workspace configuration"
    }
    "init.sh" = {
      content = local.init_script_content
      description = "Project initialization script"
    }
  }
}
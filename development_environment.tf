locals {
  default_vscode_settings = {
    "editor.formatOnSave" : true,
    "editor.rulers" : [80, 120],
    "[terraform]" : {
      "editor.defaultFormatter" : "hashicorp.terraform",
      "editor.formatOnSave" : true,
      "editor.formatOnSaveMode" : "file"
    }
  }

  effective_vscode = {
    settings = merge(local.default_vscode_settings, try(var.vs_code_workspace.settings, {}))
    extensions = {
      recommended = distinct(concat(
        try(var.vs_code_workspace.extensions.recommended, []),
        try(var.vs_code_workspace.extensions.required, []),
        ["github.copilot", "github.copilot-chat"]
      ))
    }
    tasks                 = try(var.vs_code_workspace.tasks, [])
    launch_configurations = try(var.vs_code_workspace.launch_configurations, [])
  }

  effective_devcontainer = var.development_container != null ? {
    base_image = var.development_container.base_image
    vs_code_extensions = distinct(concat(
      local.effective_vscode.extensions.recommended,
      try(var.development_container.vs_code_extensions, [])
    ))
    ports                = try(var.development_container.ports, [])
    env_vars             = try(var.development_container.env_vars, {})
    post_create_commands = try(var.development_container.post_create_commands, [])
    docker_compose = try(var.development_container.docker_compose, {
      enabled  = false
      services = {}
    })
    } : {
    base_image           = "ubuntu:latest"
    vs_code_extensions   = []
    ports                = []
    env_vars             = {}
    post_create_commands = []
    docker_compose = {
      enabled  = false
      services = {}
    }
  }
}

# Configuration moved to base_repository_files module
module "development_files" {
  source = "./modules/repository_files"

  repository = module.base_repo.github_repo.name
  branch     = module.base_repo.default_branch
  files      = {} # Empty since configurations are now in base_repository_files

  depends_on = [module.base_repo]
}

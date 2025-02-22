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

  development_container = can(var.development_container) ? {
    base_image = try(var.development_container.base_image, "ubuntu:latest")
    vs_code_extensions = distinct(concat(
      try(var.development_container.vs_code_extensions, []),
      ["github.copilot", "github.copilot-chat", "eamodio.gitlens"]
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

  # Development environment files that will be added to repositories
  devcontainer_files = var.setup_dev_container ? [
    {
      content = jsonencode({
        name = var.project_name
        build = {
          dockerfile = "Dockerfile"
          context    = "."
        }
        customizations = {
          vscode = {
            extensions = local.development_container.vs_code_extensions
          }
        }
        containerEnv      = local.development_container.env_vars
        forwardPorts      = local.development_container.ports
        postCreateCommand = join(" && ", local.development_container.post_create_commands)
      })
      name = ".devcontainer/devcontainer.json"
    },
    {
      content = templatefile("${path.module}/templates/Dockerfile", {
        base_image = local.development_container.base_image
      })
      name = ".devcontainer/Dockerfile"
    }
  ] : []
}

# Development environment files are now handled by the base_repository_files module
module "development_files" {
  source = "./modules/repository_files"
  count = can(var.development_container) ? 1 : 0
  repository = module.base_repo.github_repo.name
  branch     = module.base_repo.default_branch
  files      = local.devcontainer_files

  depends_on = [module.base_repo]
}

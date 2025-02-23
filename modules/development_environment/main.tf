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

  # Development environment files
  files = var.setup_dev_container ? [
    {
      name = ".devcontainer/devcontainer.json"
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
    },
    {
      name = ".devcontainer/Dockerfile"
      content = templatefile("${path.module}/templates/Dockerfile.tpl", {
        base_image = local.development_container.base_image
      })
    }
  ] : []
}

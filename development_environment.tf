locals {
  default_vscode_settings = {
    "editor.formatOnSave": true,
    "editor.rulers": [80, 120],
    "[terraform]": {
      "editor.defaultFormatter": "hashicorp.terraform",
      "editor.formatOnSave": true,
      "editor.formatOnSaveMode": "file"
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
    tasks = try(var.vs_code_workspace.tasks, [])
    launch_configurations = try(var.vs_code_workspace.launch_configurations, [])
  }

  effective_devcontainer = var.development_container != null ? {
    base_image = var.development_container.base_image
    vs_code_extensions = distinct(concat(
      local.effective_vscode.extensions.recommended,
      try(var.development_container.vs_code_extensions, [])
    ))
    ports = try(var.development_container.ports, [])
    env_vars = try(var.development_container.env_vars, {})
    post_create_commands = try(var.development_container.post_create_commands, [])
    docker_compose = {
      enabled = try(var.development_container.docker_compose.enabled, false)
      services = try(var.development_container.docker_compose.services, {})
    }
  } : null

  effective_codespaces = {
    machine_type = try(var.codespaces.machine_type, "medium")
    prebuild_enabled = try(var.codespaces.prebuild_enabled, false)
    retention_days = try(var.codespaces.retention_days, 30)
    env_vars = try(var.codespaces.env_vars, {})
  }
}

resource "github_repository_file" "devcontainer" {
  for_each   = var.development_container != null ? { for repo in var.repositories : repo.name => repo } : {}
  repository = module.project_repos[each.key].github_repo.name
  branch     = module.project_repos[each.key].default_branch
  file       = ".devcontainer/devcontainer.json"
  content = jsonencode({
    name  = "${each.key}-dev"
    image = local.effective_devcontainer.base_image
    customizations = {
      vscode = {
        extensions = local.effective_devcontainer.vs_code_extensions
        settings   = local.effective_vscode.settings
      }
    }
    forwardPorts      = local.effective_devcontainer.ports
    runArgs           = [for port in local.effective_devcontainer.ports : "-p ${port}:${port}"]
    remoteEnv         = local.effective_devcontainer.env_vars
    postCreateCommand = join(" && ", local.effective_devcontainer.post_create_commands)
    features = {
      "ghcr.io/devcontainers/features/docker-in-docker" = {
        version = "latest"
        moby    = true
      }
    }
  })
  commit_message      = "Add DevContainer configuration"
  overwrite_on_create = true
  depends_on          = [module.project_repos]
}

resource "github_repository_file" "docker_compose" {
  for_each = var.development_container != null && try(local.effective_devcontainer.docker_compose.enabled, false) ? {
    for repo in var.repositories : repo.name => repo
  } : {}
  repository = module.project_repos[each.key].github_repo.name
  branch     = module.project_repos[each.key].default_branch
  file       = ".devcontainer/docker-compose.yml"
  content = yamlencode({
    version  = "3.8"
    services = local.effective_devcontainer.docker_compose.services
  })
  commit_message      = "Add Docker Compose configuration for development"
  overwrite_on_create = true
  depends_on          = [module.project_repos]
}

resource "github_repository_file" "workspace_config" {
  count      = 1 # Always create the workspace file
  repository = module.base_repo.github_repo.name
  branch     = module.base_repo.default_branch
  file       = "${var.project_name}.code-workspace"
  content = jsonencode({
    folders = concat(
      [
        {
          name = var.project_name
          path = "./${var.project_name}"
        }
      ],
      [
        for repo in var.repositories : {
          name = repo.name
          path = "./${repo.name}"
        }
      ]
    )
    settings = local.effective_vscode.settings
    extensions = {
      recommendations = local.effective_vscode.extensions.recommended
      unwantedRecommendations = []
    }
    tasks = local.effective_vscode.tasks
    launch = {
      version        = "0.2.0"
      configurations = local.effective_vscode.launch_configurations
    }
  })
  commit_message      = "Update VS Code workspace configuration"
  overwrite_on_create = true
  depends_on          = [module.base_repo]
}

resource "github_repository_file" "codespaces" {
  for_each   = var.codespaces != null ? { for repo in var.repositories : repo.name => repo } : {}
  repository = module.project_repos[each.key].github_repo.name
  branch     = module.project_repos[each.key].default_branch
  file       = ".devcontainer/codespaces.json"
  content = jsonencode({
    machine = {
      type = local.effective_codespaces.machine_type
    }
    prebuild = {
      enabled = local.effective_codespaces.prebuild_enabled
    }
    retention = {
      days = local.effective_codespaces.retention_days
    }
    customizations = {
      codespaces = {
        repositories = {
          "user/*" = {
            customProperties = {
              environment = merge(
                local.effective_codespaces.env_vars,
                { GITHUB_CODESPACES = "true" }
              )
            }
          }
        }
      }
    }
    gitConfig = {
      "pull.rebase"   = "true"
      "core.autocrlf" = "input"
    }
  })
  commit_message      = "Add GitHub Codespaces configuration"
  overwrite_on_create = true
  depends_on          = [module.project_repos]
}
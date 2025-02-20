locals {
  default_devcontainer = {
    base_image = "ubuntu:22.04"
    install_tools = ["git", "curl", "make"]
    vs_code_extensions = ["github.copilot"]
    env_vars = {
      ENVIRONMENT = "development"
    }
    ports = []
  }

  # Language-specific DevContainer configurations
  language_devcontainers = {
    python = {
      base_image = "python:3.11"
      install_tools = ["pip", "poetry"]
      vs_code_extensions = [
        "ms-python.python",
        "ms-python.vscode-pylance",
        "ms-python.black-formatter"
      ]
    }
    node = {
      base_image = "node:lts"
      install_tools = ["npm", "yarn"]
      vs_code_extensions = [
        "dbaeumer.vscode-eslint",
        "esbenp.prettier-vscode"
      ]
    }
    go = {
      base_image = "golang:latest"
      install_tools = ["golangci-lint"]
      vs_code_extensions = ["golang.go"]
    }
    java = {
      base_image = "eclipse-temurin:17-jdk"
      install_tools = ["maven", "gradle"]
      vs_code_extensions = [
        "vscjava.vscode-java-pack",
        "redhat.java"
      ]
    }
  }

  # Default VS Code workspace settings when enabled
  default_vscode_settings = {
    "editor.formatOnSave": true,
    "files.trimTrailingWhitespace": true,
    "files.insertFinalNewline": true,
    "editor.rulers": [80, 100],
    "files.encoding": "utf8",
    "files.eol": "\n"
  }

  # Default Codespaces configuration
  default_codespaces = {
    machine_type = "medium"
    retention_days = 30
    prebuild_enabled = false
    env_vars = {}
    secrets = []
  }

  # Computed development container configuration (only when enabled)
  effective_devcontainer = var.development_container != null ? merge(
    {
      base_image = "ubuntu:22.04"
      install_tools = ["git", "curl", "make"]
      vs_code_extensions = ["github.copilot"]
      env_vars = {
        ENVIRONMENT = "development"
      }
      ports = []
      post_create_commands = []
    },
    var.development_container
  ) : null

  # Computed VS Code workspace configuration (only when enabled)
  effective_vscode = var.vs_code_workspace != null ? {
    settings = merge(local.default_vscode_settings, try(var.vs_code_workspace.settings, {}))
    extensions = {
      recommended = distinct(concat(
        try(var.vs_code_workspace.extensions.recommended, []),
        ["github.copilot"]
      ))
      required = try(var.vs_code_workspace.extensions.required, [])
    }
    tasks = try(var.vs_code_workspace.tasks, [])
    launch_configurations = try(var.vs_code_workspace.launch_configurations, [])
  } : null

  # Computed Codespaces configuration (only when enabled)
  effective_codespaces = var.codespaces != null ? merge(
    {
      machine_type = "medium"
      retention_days = 30
      prebuild_enabled = false
      env_vars = {}
      secrets = []
    },
    var.codespaces
  ) : null
}
locals {
  default_devcontainer = {
    base_image         = "ubuntu:22.04"
    install_tools      = ["git", "curl", "make"]
    vs_code_extensions = ["github.copilot"]
    env_vars = {
      ENVIRONMENT = "development"
    }
    ports = []
  }

  # Language-specific DevContainer configurations
  language_devcontainers = {
    python = {
      base_image    = "python:3.11"
      install_tools = ["pip", "poetry"]
      vs_code_extensions = [
        "ms-python.python",
        "ms-python.vscode-pylance",
        "ms-python.black-formatter"
      ]
    }
    node = {
      base_image    = "node:lts"
      install_tools = ["npm", "yarn"]
      vs_code_extensions = [
        "dbaeumer.vscode-eslint",
        "esbenp.prettier-vscode"
      ]
    }
    go = {
      base_image         = "golang:latest"
      install_tools      = ["golangci-lint"]
      vs_code_extensions = ["golang.go"]
    }
    java = {
      base_image    = "eclipse-temurin:17-jdk"
      install_tools = ["maven", "gradle"]
      vs_code_extensions = [
        "vscjava.vscode-java-pack",
        "redhat.java"
      ]
    }
  }

  # Default VS Code workspace settings - generic for all developers
  default_vscode_settings = {
    # Basic editor settings
    "editor.formatOnSave" : true,
    "editor.rulers" : [80, 120],
    "editor.detectIndentation" : true,
    "editor.tabSize" : 2,
    "editor.insertSpaces" : true,
    "editor.wordWrap" : "off",

    # Files and search
    "files.trimTrailingWhitespace" : true,
    "files.insertFinalNewline" : true,
    "files.trimFinalNewlines" : true,
    "files.encoding" : "utf8",
    "files.eol" : "\n",
    "search.exclude" : {
      "**/node_modules" : true,
      "**/bower_components" : true,
      "**/*.code-search" : true,
      "**/dist" : true,
      "**/coverage" : true
    },

    # Git settings
    "git.enableSmartCommit" : true,
    "git.confirmSync" : false,
    "git.autofetch" : true,

    # Terminal settings
    "terminal.integrated.scrollback" : 5000,
    "terminal.integrated.enableMultiLinePasteWarning" : false,

    # Explorer settings
    "explorer.confirmDelete" : true,
    "explorer.confirmDragAndDrop" : true,

    # Workbench settings
    "workbench.editor.enablePreview" : false,
    "workbench.startupEditor" : "none",
    "workbench.colorTheme" : "Default Dark Modern"
  }

  # Default Codespaces configuration
  default_codespaces = {
    machine_type     = "medium"
    retention_days   = 30
    prebuild_enabled = false
    env_vars         = {}
    secrets          = []
  }

  # Computed development container configuration (only when enabled)
  effective_devcontainer = var.development_container != null ? merge(
    local.default_devcontainer,
    try(local.language_devcontainers[var.development_container.language], {}),
    var.development_container
  ) : null

  # Computed VS Code workspace configuration (only when enabled)
  effective_vscode = {
    settings              = merge(local.default_vscode_settings, try(var.vs_code_workspace.settings, {}))
    extensions            = try(var.vs_code_workspace.extensions, { recommended = [], required = [] })
    tasks                 = try(var.vs_code_workspace.tasks, [])
    launch_configurations = try(var.vs_code_workspace.launch_configurations, [])
  }

  # Computed Codespaces configuration (only when enabled)
  effective_codespaces = var.codespaces != null ? merge(
    local.default_codespaces,
    var.codespaces
  ) : null
}
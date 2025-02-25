# This Terraform configuration manages development environment settings for VS Code workspaces
# and development containers, including extensions, settings, and workspace configurations.

locals {
  # Default VS Code settings that will be applied to all workspaces
  # These settings ensure consistent formatting and editor behavior across the team
  default_vscode_settings = {
    "editor.formatOnSave" : true,
    "editor.rulers" : [80, 120],
    "[terraform]" : {
      "editor.defaultFormatter" : "hashicorp.terraform",
      "editor.formatOnSave" : true,
      "editor.formatOnSaveMode" : "file"
    },
    "files.exclude" : {
      "**/.git" : true,
      "**/.DS_Store" : true
    },
    "workbench.iconTheme" : "vscode-icons",
    "editor.inlineSuggest.enabled" : true,
    "github.copilot.enable" : {
      "*" : true
    },
    # Add required variables for copilot-workspace configuration
    "project_name" : var.project_name,
    "repo_org" : var.repo_org
  }

  # Maps repository topics to relevant VS Code extensions
  # This allows automatic extension recommendations based on the technologies used in each repository
  topic_extension_mappings = {
    "terraform" = [
      "hashicorp.terraform",
      "hashicorp.hcl"
    ],
    "python" = [
      "ms-python.python",
      "ms-python.vscode-pylance"
    ],
    "javascript" = [
      "dbaeumer.vscode-eslint",
      "esbenp.prettier-vscode"
    ],
    "typescript" = [
      "ms-typescript-javascript.typescript-javascript",
      "dbaeumer.vscode-eslint"
    ]
  }

  # Processes and flattens all extensions needed based on repository topics
  # This creates a unique list of extensions by analyzing all repository topics
  topic_based_extensions = distinct(flatten([
    for repo in var.repositories :
    flatten([
      for topic in try(repo.github_repo_topics, []) :
      try(local.topic_extension_mappings[lower(topic)], [])
    ])
  ]))

  # Processes and validates documentation folder paths
  # Ensures all documentation paths are properly formatted and located under .gproj/docs/{orgName}/{repoName} directory
  doc_folders = [
    for source in var.documentation_sources : {
      name = source.name
      path = "${var.docs_base_path}/${var.repo_org}/${var.project_name}/${source.name}"
    }
  ]

  # Processes and validates repository folder paths
  # Ensures all repository paths are relative to the parent directory
  repo_folders = [
    for repo in var.repositories : {
      name = repo.name
      path = "../${repo.name}"
    }
  ]

  # Combines all workspace folders into a single distinct list
  # This includes repository folders, documentation folders, and additional workspace files
  workspace_folders = distinct(concat(
    local.repo_folders,
    local.doc_folders,
    var.workspace_files
  ))

  # Processes and combines VS Code settings
  # Merges default settings with any custom settings provided
  effective_vscode = {
    settings = merge(local.default_vscode_settings, try(var.vs_code_workspace.settings, {}))
    extensions = {
      recommended = distinct(concat(
        local.topic_based_extensions,
        try(var.vs_code_workspace.extensions.recommended, []),
        try(var.vs_code_workspace.extensions.required, []),
        ["github.copilot", "github.copilot-chat", "eamodio.gitlens"]
      ))
    }
    tasks                 = try(var.vs_code_workspace.tasks, [])
    launch_configurations = try(var.vs_code_workspace.launch_configurations, [])
  }

  # Development container configuration with default values
  # Configures the development environment when using VS Code Remote Containers
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
  } : null

  # Generates all required development environment files
  # This includes DevContainer configuration and VS Code workspace settings
  files = concat(
    var.setup_dev_container ? [
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
    ] : [],
    # VS Code workspace configuration with validated paths
    [
      {
        name = "${var.project_name}.code-workspace"
        content = jsonencode({
          folders  = local.workspace_folders
          settings = local.effective_vscode.settings
          extensions = {
            recommendations = local.effective_vscode.extensions.recommended
          }
          tasks = local.effective_vscode.tasks
          launch = {
            version        = "0.2.0"
            configurations = local.effective_vscode.launch_configurations
          }
        })
      }
    ]
  )
}

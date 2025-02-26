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
    "project_name" : var.project_name
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

  # Extract repository name from URL or org/repo format
  extract_repo_name = { for source in var.documentation_sources :
    source.name => (
      length(regexall("^git@", source.repo)) > 0 ?
        # SSH format: git@github.com:org/repo.git
        element(split("/", regex("^git@[^:]+:([^/]+/[^.]+)(?:\\.git)?$", source.repo)[0]), 1) :
      length(regexall("^https?://", source.repo)) > 0 ?
        # HTTPS format: https://github.com/org/repo
        element(split("/", regex("^https?://[^/]+/([^/]+/[^/]+?)(?:\\.git)?/?$", source.repo)[0]), 1) :
      # Plain format: org/repo
      element(split("/", source.repo), 1)
    )
  }

  # Process documentation sources to maintain consistent paths
  doc_folders = distinct([
    for source in var.documentation_sources : {
      name = source.name
      path = join("/", compact([
        var.docs_base_path,
        local.extract_repo_name[source.name],
        trimsuffix(source.path, ".")
      ]))
    }
  ])

  # Process repository paths (excluding base repo)
  repo_folders = distinct([
    for repo in var.repositories : {
      name = repo.name
      path = "../${repo.name}"
    }
  ])

  # Combines all workspace folders into a single distinct list
  # Base repo is first, followed by other repos and doc folders
  workspace_folders = concat(
    # Base repo (current directory)
    [{
      name = var.project_name
      path = "."
    }],
    # Other repositories and documentation folders
    local.repo_folders,
    local.doc_folders,
    var.workspace_files
  )

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

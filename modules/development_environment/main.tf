locals {
  default_vscode_settings = {
    "editor.formatOnSave" : true,
    "editor.rulers" : [80, 120],
    "[terraform]" : {
      "editor.defaultFormatter" : "hashicorp.terraform",
      "editor.formatOnSave" : true,
      "editor.formatOnSaveMode" : "file"
    },
    "files.exclude": {
      "**/.git": true,
      "**/.DS_Store": true
    },
    "workbench.iconTheme": "vscode-icons",
    "editor.inlineSuggest.enabled": true,
    "github.copilot.enable": {
      "*": true
    }
  }

  # Topic to extension mappings
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

  # Process extensions based on repository topics
  topic_based_extensions = distinct(flatten([
    for repo in var.repositories :
    flatten([
      for topic in try(repo.github_repo_topics, []) :
      try(local.topic_extension_mappings[lower(topic)], [])
    ])
  ]))

  # Documentation folders for workspace
  doc_folders = [
    for source in var.documentation_sources : {
      name = source.name
      path = "${var.docs_base_path}/${source.name}/${source.path}"
    }
  ]

  # Workspace folders (combine existing and documentation folders)
  workspace_folders = concat(
    [for repo in var.repositories : {
      name = repo.name
      path = "../${repo.name}"
    }],
    local.doc_folders
  )

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

  # .projg configuration
  projg_config = {
    docs_base_path = var.docs_base_path
    documentation_sources = var.documentation_sources
  }

  # Development environment files
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
    # VS Code workspace configuration
    [
      {
        name = "${var.project_name}.code-workspace"
        content = jsonencode({
          folders = local.workspace_folders
          settings = local.effective_vscode.settings
          extensions = {
            recommendations = local.effective_vscode.extensions.recommended
          }
          tasks = local.effective_vscode.tasks
          launch = {
            version = "0.2.0"
            configurations = local.effective_vscode.launch_configurations
          }
        })
      }
    ],
    # .projg configuration
    [
      {
        name = ".projg"
        content = jsonencode(local.projg_config)
      }
    ]
  )
}

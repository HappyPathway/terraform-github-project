variable "project_name" {
  type        = string
  description = "Name of the project"
}

variable "vs_code_workspace" {
  type = object({
    settings = optional(map(any))
    extensions = optional(object({
      recommended = optional(list(string))
      required    = optional(list(string))
    }))
    tasks                 = optional(list(any))
    launch_configurations = optional(list(any))
  })
  default     = {}
  description = "VS Code workspace configuration"
}

variable "development_container" {
  type = object({
    base_image           = optional(string)
    vs_code_extensions   = optional(list(string))
    ports                = optional(list(number))
    env_vars             = optional(map(string))
    post_create_commands = optional(list(string))
    docker_compose = optional(object({
      enabled  = optional(bool)
      services = optional(map(any))
    }))
  })
  default     = null
  description = "Development container configuration"
}

variable "setup_dev_container" {
  type        = bool
  default     = false
  description = "Whether to set up a development container"
}

variable "workspace_files" {
  type = list(object({
    name = string
    path = string
  }))
  default     = []
  description = "Additional files to include in the VS Code workspace configuration"
}

variable "repositories" {
  type = list(any)
  description = "List of repositories to include in the workspace"
}

variable "documentation_sources" {
  type = list(object({
    repo = string
    name = string
    path = string
    tag  = optional(string, "main")
  }))
  description = "List of external repositories to clone as documentation/reference sources"
  default     = []
}

variable "docs_base_path" {
  type        = string
  description = "Base path where documentation repositories will be cloned. Supports environment variables (${VAR}) and shell expansion (~)"
  default     = "~/.projg/docs"
}

locals {
  workspace_folders = concat(
    [{
      name = var.project_name
      path = "."
    }],
    [for repo in var.repositories : {
      name = repo.name
      path = "../${repo.name}"
    }],
    var.workspace_files
  )
}

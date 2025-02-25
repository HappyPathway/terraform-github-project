variable "project_name" {
  type        = string
  description = "Name of the project"
}

variable "repo_org" {
  type        = string
  description = "GitHub organization or username that owns the repositories"
}

variable "project_prompt" {
  type        = string
  description = "Project prompt for GitHub Copilot configuration"
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

  validation {
    condition = alltrue([
      for file in var.workspace_files :
      can(regex("^[^<>:\"|?*]+$", file.path)) # Disallow invalid path characters
    ])
    error_message = "Workspace file paths contain invalid characters. Paths must not contain: < > : \" | ? *"
  }
}

variable "repositories" {
  type = list(object({
    name = string
    topics = optional(list(string), [])
  }))
  description = "List of repositories to include in the workspace. Each repository can specify its own host."
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

  validation {
    condition = alltrue([
      for source in var.documentation_sources : (
        can(regex("^(https://|git@)", source.repo)) &&                     # Must be HTTPS or SSH URL
        can(regex("^[a-zA-Z0-9/_-]+$", source.name)) &&                   # Alphanumeric + common separators
        (source.path == null || can(regex("^[^<>:\"|?*]+$", source.path))) # Valid path if specified
      )
    ])
    error_message = "Documentation sources must use valid Git URLs (HTTPS or SSH), have valid names (alphanumeric with - and _), and valid paths"
  }
}

variable "docs_base_path" {
  type        = string
  description = "Base path where documentation repositories will be cloned. Supports environment variables (VAR) and shell expansion (~)"
  default     = "~/.gproj/docs"

  validation {
    condition     = can(regex("^[~$][^<>:\"|?*]+$", var.docs_base_path))
    error_message = "docs_base_path must start with ~ or $ and contain only valid path characters"
  }
}

variable "github_host" {
  description = "The GitHub host to use. Defaults to github.com, but can be set to a custom GitHub Enterprise host"
  type        = string
  default     = "github.com"
}

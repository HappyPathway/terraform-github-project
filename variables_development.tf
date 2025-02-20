variable "development_container" {
  description = "Configuration for development containers across repositories"
  type = object({
    base_image        = string
    install_tools     = optional(list(string), [])
    vs_code_extensions = optional(list(string), [])
    env_vars         = optional(map(string), {})
    ports            = optional(list(string), [])
    post_create_commands = optional(list(string), [])
    docker_compose   = optional(object({
      enabled = bool
      services = map(object({
        image = string
        ports = list(string)
        environment = map(string)
      }))
    }))
  })
  default = null
}

variable "vs_code_workspace" {
  description = "Configuration for VS Code workspace settings"
  type = object({
    settings = optional(map(any), {})
    extensions = optional(object({
      recommended = optional(list(string), [])
      required = optional(list(string), [])
    }))
    tasks = optional(list(object({
      name = string
      command = string
      group = optional(string)
      options = optional(map(string))
    })), [])
    launch_configurations = optional(list(object({
      name = string
      type = string
      request = string
      configuration = map(any)
    })), [])
  })
  default = null
}

variable "codespaces" {
  description = "Configuration for GitHub Codespaces"
  type = object({
    machine_type = optional(string, "medium")
    retention_days = optional(number, 30)
    prebuild_enabled = optional(bool, false)
    env_vars = optional(map(string), {})
    secrets = optional(list(string), [])
    dotfiles_repository = optional(string)
    custom_image = optional(string)
  })
  default = null
}
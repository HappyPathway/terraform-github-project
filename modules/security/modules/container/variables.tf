variable "repositories" {
  description = "List of repository configurations to analyze for container security patterns"
  type = list(object({
    name               = string
    github_repo_topics = optional(list(string))
    prompt             = optional(string)
  }))
}

variable "container_security_config" {
  description = "Configuration for container security features"
  type = object({
    scanning_tools    = optional(list(string), [])
    runtime_security  = optional(list(string), [])
    registry_security = optional(list(string), [])
    uses_distroless   = optional(bool, false)
  })
}
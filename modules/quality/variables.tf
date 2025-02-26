variable "repositories" {
  description = "List of repository configurations to analyze for code quality patterns"
  type = list(object({
    name               = string
    github_repo_topics = optional(list(string))
    prompt             = optional(string)
  }))
}

variable "quality_config" {
  description = "Configuration for code quality requirements"
  type = object({
    linting_required       = optional(bool, true)
    type_safety            = optional(bool, true)
    documentation_required = optional(bool, true)
    formatting_tools       = optional(list(string), [])
    linting_tools          = optional(list(string), [])
    documentation_tools    = optional(list(string), [])
  })
  default = {}
}
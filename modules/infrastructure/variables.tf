variable "repositories" {
  description = "List of repository configurations to analyze for infrastructure patterns"
  type = list(object({
    name              = string
    github_repo_topics = optional(list(string))
    prompt            = optional(string)
  }))
}

variable "iac_config" {
  description = "Infrastructure as Code configuration"
  type = object({
    iac_tools = optional(list(string), [])
    cloud_providers = optional(list(string), [])
    documentation_tools = optional(list(string), ["terraform-docs"])
    testing_frameworks = optional(list(string), [])
  })
  default = {}
}
variable "repositories" {
  description = "List of repository configurations to analyze for development and deployment patterns"
  type = list(object({
    name              = string
    github_repo_topics = optional(list(string))
    prompt            = optional(string)
  }))
}

variable "testing_requirements" {
  description = "Configuration for testing requirements"
  type = object({
    required = optional(bool, true)
    coverage_threshold = optional(number, 80)
  })
  default = {}
}

variable "ci_cd_config" {
  description = "Configuration for CI/CD tooling and patterns"
  type = object({
    ci_cd_tools = optional(list(string), [])
    required_status_checks = optional(list(string), [])
  })
  default = {}
}
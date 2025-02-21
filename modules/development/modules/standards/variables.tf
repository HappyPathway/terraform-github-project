variable "repositories" {
  description = "List of repository configurations to analyze for development standards"
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
variable "repositories" {
  description = "List of repository configurations to analyze for compliance patterns"
  type = list(object({
    name              = string
    github_repo_topics = optional(list(string))
    prompt            = optional(string)
  }))
}

variable "security_frameworks" {
  description = "List of security frameworks to implement"
  type        = list(string)
  default     = []
}
variable "project_name" {
  description = "Name of the project"
  type        = string
}

variable "repositories" {
  description = "List of repositories to analyze and create copilot files for"
  type = list(object({
    name                  = string
    github_repo_topics    = optional(list(string), [])
    github_default_branch = optional(string, "main")
    prompt                = string
  }))
}

variable "copilot_instructions" {
  description = "Custom Copilot instructions. If not provided, instructions will be generated from templates"
  type        = string
  default     = null
}

variable "enforce_prs" {
  description = "Whether pull requests are enforced"
  type        = bool
  default     = true
}

variable "github_pro_enabled" {
  description = "Whether GitHub Pro features are available"
  type        = bool
  default     = false
}

variable "wait_for_repositories" {
  description = "List of repository resources to wait for before creating files"
  type        = any
  default     = []
}
variable "repository" {
  type        = string
  description = "The name of the repository to manage files for"

  validation {
    condition     = length(var.repository) > 0
    error_message = "Repository name cannot be empty"
  }
}

variable "branch" {
  type        = string
  description = "The branch to create/update files in"

  validation {
    condition     = length(var.branch) > 0
    error_message = "Branch name cannot be empty"
  }
}

variable "files" {
  type = list(object({
    name    = string
    content = string
  }))
  description = "List of files to manage in the repository"
}

variable "overwrite_on_create" {
  description = "Enable overwriting existing files"
  type        = bool
  default     = true
}

variable "mkfiles" {
  type        = bool
  description = "Whether to create repository files. Set to false for initial repo creation, then true to create files."
  default     = false
}
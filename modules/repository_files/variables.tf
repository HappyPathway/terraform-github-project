variable "repository" {
  description = "The name of the GitHub repository"
  type        = string
}

variable "branch" {
  description = "The branch to create/update files in"
  type        = string
  default     = "main"
}

variable "files" {
  description = "List of files to create or update in the repository"
  type = list(object({
    content = string
    name    = string
  }))
}

variable "overwrite_on_create" {
  description = "Enable overwriting existing files"
  type        = bool
  default     = true
}
variable "repo_org" {
  description = "GitHub organization name"
  type        = string
}

variable "project_name" {
  description = "Name of the project. Will be used as the base repository name."
  type        = string
}

variable "project_prompt" {
  description = "Content for the project's prompt file"
  type        = string
}
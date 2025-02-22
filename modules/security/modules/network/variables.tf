variable "repositories" {
  description = "List of repository configurations to analyze for network security patterns"
  type = list(object({
    name               = string
    github_repo_topics = optional(list(string))
    prompt             = optional(string)
  }))
}
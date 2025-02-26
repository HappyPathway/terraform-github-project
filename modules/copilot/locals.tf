locals {
  copilot_instructions = try(var.copilot_instructions, "")
  detected_languages = distinct(flatten([
    for repo in var.repositories : try(repo.github_repo_topics, [])
    if can(regex("^(python|javascript|typescript|go|java|ruby|php|c#|rust|kotlin|swift)$", repo.github_repo_topics[0]))
  ]))
  detected_frameworks = distinct(flatten([
    for repo in var.repositories : try(repo.github_repo_topics, [])
    if can(regex("^(react|angular|vue|django|flask|spring|rails|laravel)$", repo.github_repo_topics[0]))
  ]))
  detected_testing_tools = distinct(flatten([
    for repo in var.repositories : try(repo.github_repo_topics, [])
    if can(regex("^(jest|pytest|mocha|junit|rspec)$", repo.github_repo_topics[0]))
  ]))
  detected_iac_tools = distinct(flatten([
    for repo in var.repositories : try(repo.github_repo_topics, [])
    if can(regex("^(terraform|cloudformation|ansible|puppet|chef)$", repo.github_repo_topics[0]))
  ]))
  detected_cloud_providers = distinct(flatten([
    for repo in var.repositories : try(repo.github_repo_topics, [])
    if can(regex("^(aws|azure|gcp|google-cloud)$", repo.github_repo_topics[0]))
  ]))
  detected_security_tools = distinct(flatten([
    for repo in var.repositories : try(repo.github_repo_topics, [])
    if can(regex("^(snyk|sonarqube|owasp|security)$", repo.github_repo_topics[0]))
  ]))
  detected_linting_tools = distinct(flatten([
    for repo in var.repositories : try(repo.github_repo_topics, [])
    if can(regex("^(eslint|pylint|golint)$", repo.github_repo_topics[0]))
  ]))

  generated_copilot_instructions = var.copilot_instructions != null ? var.copilot_instructions : <<-EOT
## Project Technologies
${join("\n", [for lang in local.detected_languages : "- ${lang}"])}
## Frameworks
${join("\n", [for framework in local.detected_frameworks : "- ${framework}"])}
## Testing
${join("\n", [for tool in local.detected_testing_tools : "- ${tool}"])}
## Infrastructure
${join("\n", [for tool in local.detected_iac_tools : "- ${tool}"])}
${join("\n", [for provider in local.detected_cloud_providers : "- ${provider}"])}
## Security and Quality
${join("\n", [for tool in concat(local.detected_security_tools, local.detected_linting_tools) : "- ${tool}"])}
## Testing Requirements
Tests must not require GitHub Pro features.
EOT

  repository_files = {
    for repo in var.repositories : repo.name => {
      repo_prompt = lookup(repo, "prompt", null) != null ? {
        path    = ".github/prompts/${repo.name}.prompt.md"  # Repo-specific prompts stay in .github/prompts/
        content = repo.prompt
      } : null
    }
  }

  # Files to be created (only repo-specific prompts)
  files = flatten([
    for repo_name, files in local.repository_files : [
      files.repo_prompt == null ? {} : {
        name    = files.repo_prompt.path
        content = files.repo_prompt.content
      }
    ]
  ])
}
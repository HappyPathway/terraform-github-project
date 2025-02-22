locals {
  # Analyze repositories to detect languages, frameworks and tools
  languages = distinct(flatten([
    for repo in var.repositories : [
      for topic in coalesce(repo.github_repo_topics, []) :
      topic if can(regex("^(python|typescript|javascript|java|go|rust|cpp|csharp|ruby)", topic))
    ]
  ]))

  frameworks = distinct(flatten([
    for repo in var.repositories : [
      for topic in coalesce(repo.github_repo_topics, []) :
      topic if can(regex("^(react|vue|angular|django|fastapi|spring|gin|actix|rails)", topic))
    ]
  ]))

  # Testing and quality patterns
  testing_tools = distinct(flatten([
    for repo in var.repositories : [
      for topic in coalesce(repo.github_repo_topics, []) :
      topic if can(regex("^(jest|pytest|junit|testify|rspec)", topic))
    ]
  ]))

  linting_tools = distinct(flatten([
    for repo in var.repositories : [
      for topic in coalesce(repo.github_repo_topics, []) :
      topic if can(regex("^(eslint|flake8|checkstyle|golangci|clippy|rubocop)", topic))
    ]
  ]))

  # Infrastructure patterns
  iac_tools = distinct(flatten([
    for repo in var.repositories : [
      for topic in coalesce(repo.github_repo_topics, []) :
      topic if can(regex("^(terraform|cloudformation|pulumi|ansible)", topic))
    ]
  ]))

  cloud_providers = distinct(flatten([
    for repo in var.repositories : [
      for topic in coalesce(repo.github_repo_topics, []) :
      topic if can(regex("^(aws|azure|gcp|alibaba)", topic))
    ]
  ]))

  # Security and compliance patterns
  security_tools = distinct(flatten([
    for repo in var.repositories : [
      for topic in coalesce(repo.github_repo_topics, []) :
      topic if can(regex("^(snyk|trivy|sonarqube|fortify|veracode)", topic))
    ]
  ]))

  # Generate copilot instructions
  copilot_instructions = coalesce(var.copilot_instructions, templatefile("${path.module}/templates/copilot_instructions.tpl", {
    project_name       = var.project_name
    languages          = local.languages
    frameworks         = local.frameworks
    testing_tools      = local.testing_tools
    linting_tools      = local.linting_tools
    iac_tools          = local.iac_tools
    cloud_providers    = local.cloud_providers
    security_tools     = local.security_tools
    enforce_prs        = var.enforce_prs
    github_pro_enabled = var.github_pro_enabled
  }))

  # Generate copilot instructions
  generated_copilot_instructions = <<-EOT
# Generated GitHub Copilot Instructions

## Project Languages
${join("\n", [for lang in local.languages : "- ${lang}"])}

## Frameworks
${join("\n", [for framework in local.frameworks : "- ${framework}"])}

## Testing
${join("\n", [for tool in local.testing_tools : "- ${tool}"])}

## Infrastructure
${join("\n", [for tool in local.iac_tools : "- ${tool}"])}
${join("\n", [for provider in local.cloud_providers : "- ${provider}"])}

## Security and Quality
${join("\n", [for tool in concat(local.security_tools, local.linting_tools) : "- ${tool}"])}

## Testing Requirements
Tests must not require GitHub Pro features.
EOT

  # Map of repository file contents
  repository_files = {
    for repo in var.repositories : repo.name => {
      copilot_instructions = {
        path    = ".github/prompts/copilot-setup.md"
        content = local.copilot_instructions
      }
      repo_prompt = lookup(repo, "prompt", null) != null ? {
        path    = ".github/prompts/repo-setup.prompt.md"
        content = repo.prompt
      } : null
    }
  }
}
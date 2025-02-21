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
    project_name = var.project_name
    languages = local.languages
    frameworks = local.frameworks
    testing_tools = local.testing_tools
    linting_tools = local.linting_tools
    iac_tools = local.iac_tools
    cloud_providers = local.cloud_providers
    security_tools = local.security_tools
    enforce_prs = var.enforce_prs
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
}

# Create copilot instruction files for each repository
resource "github_repository_file" "copilot_instructions" {
  for_each = { 
    for repo in var.repositories : repo.name => repo
    if lookup(repo, "enable_copilot", true)
  }
  
  repository          = each.key
  branch             = try(each.value.github_default_branch, "main")
  file               = ".github/prompts/copilot-setup.md"
  content            = local.copilot_instructions
  commit_message     = "Add GitHub Copilot setup instructions"
  overwrite_on_create = true
}

# Create prompt files for each repository
resource "github_repository_file" "repo_prompt" {
  for_each = { 
    for repo in var.repositories : repo.name => repo 
    if lookup(repo, "prompt", null) != null
  }

  repository          = each.key
  branch             = try(each.value.github_default_branch, "main")
  file               = ".github/prompts/repo-setup.prompt.md"
  content            = each.value.prompt
  commit_message     = "Update repository prompt"
  overwrite_on_create = true
}
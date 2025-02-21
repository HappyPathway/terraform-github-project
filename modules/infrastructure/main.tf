locals {
  iac_tools = coalesce(var.iac_config.iac_tools, distinct(flatten([
    for repo in var.repositories :
    [for topic in coalesce(repo.github_repo_topics, []) :
     topic if can(regex("^(terraform|cloudformation|ansible|pulumi)", topic))]
  ])))

  cloud_providers = coalesce(var.iac_config.cloud_providers, distinct(flatten([
    for repo in var.repositories :
    [for topic in coalesce(repo.github_repo_topics, []) :
     topic if can(regex("^(aws|azure|gcp|alicloud)", topic))]
  ])))

  has_kubernetes = anytrue([
    for repo in var.repositories :
    contains(coalesce(repo.github_repo_topics, []), "kubernetes") ||
    contains(coalesce(repo.github_repo_topics, []), "k8s") ||
    contains(coalesce(repo.github_repo_topics, []), "eks") ||
    contains(coalesce(repo.github_repo_topics, []), "aks") ||
    contains(coalesce(repo.github_repo_topics, []), "gke")
  ])

  uses_terraform_modules = anytrue([
    for repo in var.repositories :
    contains(coalesce(repo.github_repo_topics, []), "terraform-module") ||
    contains(coalesce(repo.github_repo_topics, []), "infrastructure-module")
  ])

  module_documentation_tools = coalesce(var.iac_config.documentation_tools, distinct(flatten([
    for repo in var.repositories :
    [for topic in coalesce(repo.github_repo_topics, []) :
     topic if can(regex("^(terraform-docs|mkdocs|sphinx)", topic))]
  ])))

  module_testing_frameworks = coalesce(var.iac_config.testing_frameworks, distinct(flatten([
    for repo in var.repositories :
    [for topic in coalesce(repo.github_repo_topics, []) :
     topic if can(regex("^(terratest|kitchen-terraform|rspec)", topic))]
  ])))

  deployment_environment = anytrue([
    for repo in var.repositories :
    contains(coalesce(repo.github_repo_topics, []), "multi-environment") ||
    contains(coalesce(repo.github_repo_topics, []), "environment-management")
  ])

  module_config = {
    is_module = local.uses_terraform_modules
    iac_tools = local.iac_tools
    cloud_providers = local.cloud_providers
    has_kubernetes = local.has_kubernetes
    documentation_tools = local.module_documentation_tools
    testing_frameworks = local.module_testing_frameworks
    deployment_environment = local.deployment_environment
  }
}
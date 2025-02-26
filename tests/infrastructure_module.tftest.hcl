run "verify_infrastructure_patterns" {
  variables {
    project_name   = "test-infrastructure"
    repo_org       = "HappyPathway"
    project_prompt = "Test project for infrastructure patterns"
    repositories = [
      {
        name = "terraform-modules"
        github_repo_topics = [
          "terraform",
          "terraform-module",
          "aws",
          "azure",
          "terratest"
        ]
        prompt = "Core infrastructure modules"
      },
      {
        name = "kubernetes-platform"
        github_repo_topics = [
          "kubernetes",
          "helm",
          "k8s",
          "eks"
        ]
        prompt = "Kubernetes platform configuration"
      }
    ]
  }

  assert {
    condition     = contains(module.infrastructure.detected_iac_tools, "terraform")
    error_message = "Should detect Terraform as IaC tool"
  }

  assert {
    condition     = contains(module.infrastructure.detected_cloud_providers, "aws")
    error_message = "Should detect AWS as cloud provider"
  }

  assert {
    condition     = module.infrastructure.has_kubernetes
    error_message = "Should detect Kubernetes configuration"
  }

  assert {
    condition     = module.infrastructure.uses_terraform_modules
    error_message = "Should detect Terraform module usage"
  }
}

run "verify_module_patterns" {
  variables {
    repositories = [
      {
        name = "terraform-aws-vpc"
        github_repo_topics = [
          "terraform-module",
          "infrastructure-module",
          "terraform-docs",
          "terratest"
        ]
        prompt = "AWS VPC Terraform module"
      }
    ]
  }

  assert {
    condition     = length(module.infrastructure.module_documentation_tools) > 0
    error_message = "Should detect module documentation tools"
  }

  assert {
    condition     = contains(module.infrastructure.module_testing_frameworks, "terratest")
    error_message = "Should detect Terratest as testing framework"
  }

  assert {
    condition     = module.infrastructure.module_config.is_module
    error_message = "Should identify repository as a module"
  }
}
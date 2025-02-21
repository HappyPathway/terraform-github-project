mock_provider "github" {
  source = "./mocks/github.tfmock.hcl"
}

run "verify_complete_module_integration" {
  variables {
    project_name = "test-project"
    repo_org = "test-org"
    github_pro_enabled = false
    project_prompt = "Test project for complete module integration"
    repositories = [
      {
        name = "service-a"
        github_repo_topics = [
          "typescript",
          "docker",
          "terraform",
          "aws",
          "jest"
        ]
        github_is_private = false
        prompt = "TypeScript service with infrastructure"
      },
      {
        name = "service-b"
        github_repo_topics = [
          "python",
          "fastapi",
          "kubernetes",
          "pytest",
          "snyk"
        ]
        github_is_private = false
        prompt = "Python FastAPI service"
      }
    ]

    base_repository = {
      visibility = "public"
    }

    security_config = {
      enable_security_scanning = true
      security_frameworks = ["SOC2"]
      container_security_config = {
        scanning_tools = ["snyk", "trivy"]
      }
    }

    development_config = {
      testing_requirements = {
        required = true
        coverage_threshold = 85
      }
    }

    infrastructure_config = {
      iac_config = {
        iac_tools = ["terraform"]
        cloud_providers = ["aws"]
      }
    }

    quality_config = {
      linting_required = true
      type_safety = true
      documentation_required = true
    }
  }

  assert {
    condition = length(output.security_configuration.container_security.scanning_tools) > 0
    error_message = "Security module should detect container scanning tools"
  }

  assert {
    condition = length(output.development_configuration.languages) > 0
    error_message = "Development module should detect programming languages"
  }

  assert {
    condition = contains(output.infrastructure_configuration.iac_tools, "terraform")
    error_message = "Infrastructure module should detect Terraform usage"
  }

  assert {
    condition = output.quality_configuration.code_quality_config.linting_required
    error_message = "Quality module should enforce linting requirements"
  }

  assert {
    condition = output.security_configuration.compliance.security_frameworks[0] == "SOC2"
    error_message = "Security frameworks should be properly configured"
  }

  assert {
    condition = output.development_configuration.standards.testing_required
    error_message = "Testing requirements should be properly configured"
  }
}
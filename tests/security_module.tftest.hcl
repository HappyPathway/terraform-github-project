mock_provider "github" {
  source = "./tests/mocks"
}

run "verify_container_security_detection" {
  command = plan

  variables {
    project_name   = "test-container-security"
    project_prompt = "Test project for container security detection"
    repo_org       = "test-org"
    repositories = [
      {
        name               = "app-container"
        github_repo_topics = ["docker", "container-security", "trivy"]
        prompt             = "Container application with security requirements"
      },
      {
        name               = "web-service"
        github_repo_topics = ["container-registry", "registry-security"]
        prompt             = "Web service with secure container registry"
      }
    ]
  }

  # Testing input configurations rather than provider-computed values
  assert {
    condition     = can(module.security.repository_files["app-container/.github/workflows/trivy.yml"])
    error_message = "Should plan to create Trivy scanning workflow"
  }

  assert {
    condition     = can(module.security.repository_files["app-container/.github/workflows/container-security.yml"])
    error_message = "Should plan to create container security workflow"
  }
}

run "verify_network_security_detection" {
  command = plan

  variables {
    project_name   = "test-network-security"
    project_prompt = "Test project for network security detection"
    repo_org       = "test-org"
    repositories = [
      {
        name               = "service-mesh-app"
        github_repo_topics = ["service-mesh", "istio", "zero-trust"]
        prompt             = "Service mesh application with zero trust architecture"
      },
      {
        name               = "network-policy"
        github_repo_topics = ["network-policy", "security-group"]
        prompt             = "Network policy configuration"
      }
    ]
  }

  # Testing input configurations rather than provider-computed values
  assert {
    condition     = can(module.security.repository_files["service-mesh-app/.github/SECURITY.md"])
    error_message = "Should plan to create security documentation"
  }

  assert {
    condition     = can(module.security.repository_files["network-policy/.github/SECURITY.md"])
    error_message = "Should plan to create security documentation"
  }
}

run "verify_compliance_detection" {
  command = plan

  variables {
    project_name   = "test-compliance"
    project_prompt = "Test project for compliance detection"
    repo_org       = "test-org"
    repositories = [
      {
        name               = "compliance-app"
        github_repo_topics = ["compliance", "encryption", "audit"]
        prompt             = "Compliance-focused application"
      }
    ]
  }

  # Testing input configurations rather than provider-computed values
  assert {
    condition     = can(module.security.repository_files["compliance-app/.github/workflows/compliance-check.yml"])
    error_message = "Should plan to create compliance workflow"
  }

  assert {
    condition     = can(module.security.repository_files["compliance-app/.github/SECURITY.md"])
    error_message = "Should plan to create security documentation"
  }
}
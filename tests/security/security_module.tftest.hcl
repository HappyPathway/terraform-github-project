mock_provider "github" {
  source = "../mocks/github.tfmock.hcl"
}

run "verify_container_security_detection" {
  variables {
    repositories = [
      {
        name = "app-container"
        github_repo_topics = ["docker", "container-security", "trivy"]
        prompt = "Container application with security requirements"
        visibility = "public"
      },
      {
        name = "web-service"
        github_repo_topics = ["container-registry", "registry-security"]
        prompt = "Web service with secure container registry"
        visibility = "public"
      }
    ]
    
    container_security_config = {
      scanning_tools = ["trivy", "snyk"]
      runtime_security = ["falco"]
      registry_security = ["harbor"]
      uses_distroless = true
    }
  }

  command = plan

  assert {
    condition = module.container.container_scanning_required
    error_message = "Container scanning should be required based on repository topics"
  }

  assert {
    condition = module.container.registry_security_required
    error_message = "Registry security should be required based on repository topics"
  }
}

run "verify_network_security_detection" {
  variables {
    repositories = [
      {
        name = "service-mesh-app"
        github_repo_topics = ["service-mesh", "istio", "zero-trust"]
        prompt = "Service mesh application with zero trust architecture"
        visibility = "public"
      },
      {
        name = "network-policy"
        github_repo_topics = ["network-policy", "security-group"]
        prompt = "Network policy configuration"
        visibility = "public"
      }
    ]
  }

  command = plan

  assert {
    condition = module.network.network_security_config.zero_trust
    error_message = "Zero trust should be enabled based on repository topics"
  }

  assert {
    condition = module.network.network_security_config.service_mesh
    error_message = "Service mesh should be detected based on repository topics"
  }

  assert {
    condition = length(module.network.network_security_config.network_policies) > 0
    error_message = "Network policies should be detected based on repository topics"
  }
}

run "verify_compliance_detection" {
  variables {
    repositories = [
      {
        name = "compliance-app"
        github_repo_topics = ["compliance", "encryption", "audit"]
        prompt = "Compliance-focused application"
        visibility = "public"
      }
    ]
    
    security_frameworks = ["SOC2", "ISO27001"]
  }

  command = plan

  assert {
    condition = module.compliance.encryption_required
    error_message = "Encryption should be required based on repository topics"
  }

  assert {
    condition = module.compliance.audit_logging_enabled
    error_message = "Audit logging should be enabled based on repository topics"
  }

  assert {
    condition = length(module.compliance.compliance_config.compliance_frameworks) == 2
    error_message = "Security frameworks should be properly configured"
  }
}
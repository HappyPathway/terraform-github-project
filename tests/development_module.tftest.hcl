run "verify_development_standards" {
  variables {
    project_name   = "test-development-standards"
    repo_org       = "HappyPathway"
    project_prompt = "Test project for development standards"
    repositories = [
      {
        name               = "web-app"
        github_repo_topics = ["typescript", "react", "jest"]
        prompt             = "Web application with TypeScript and React"
      },
      {
        name               = "api-service"
        github_repo_topics = ["python", "fastapi", "pytest"]
        prompt             = "API service with Python and FastAPI"
      }
    ]
  }

  assert {
    condition     = length(module.standards.development_standards.languages) > 0
    error_message = "Should detect programming languages from repository topics"
  }

  assert {
    condition     = length(module.standards.development_standards.frameworks) > 0
    error_message = "Should detect frameworks from repository topics"
  }

  assert {
    condition     = module.standards.development_standards.testing_required
    error_message = "Testing should be required based on repository topics"
  }
}

run "verify_deployment_patterns" {
  variables {
    repositories = [
      {
        name               = "microservice"
        github_repo_topics = ["blue-green", "gitops", "argocd", "feature-flags"]
        prompt             = "Microservice with advanced deployment patterns"
      }
    ]
  }

  assert {
    condition     = contains(module.deployment.deployment_config.strategies, "blue-green")
    error_message = "Should detect blue-green deployment strategy"
  }

  assert {
    condition     = module.deployment.deployment_config.uses_gitops
    error_message = "Should detect GitOps usage"
  }

  assert {
    condition     = module.deployment.deployment_config.feature_flags
    error_message = "Should detect feature flags usage"
  }
}
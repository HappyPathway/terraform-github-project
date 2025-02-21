# Development Module

This module analyzes repository configurations to determine development standards and deployment patterns. It provides structured configuration for development practices and deployment strategies.

## Submodules

### Standards
- Detects programming languages
- Identifies frameworks in use
- Configures testing requirements
- Sets development tooling standards

### Deployment
- Identifies deployment strategies
- Configures CI/CD tooling
- Manages feature flag usage
- Implements GitOps practices

## Usage

```hcl
module "development" {
  source = "./modules/development"

  repositories = [
    {
      name = "web-app"
      github_repo_topics = ["typescript", "react", "jest"]
      prompt = "Web application with TypeScript and React"
    }
  ]

  testing_requirements = {
    required = true
    coverage_threshold = 80
  }

  ci_cd_config = {
    ci_cd_tools = ["github-actions"]
    required_status_checks = ["build", "test", "lint"]
  }
}
```

## Variables

### Required Variables
- `repositories` - List of repository configurations to analyze

### Optional Variables
- `testing_requirements` - Configuration for testing requirements
- `ci_cd_config` - Configuration for CI/CD tooling and patterns

## Outputs

### Development Standards
- `development_config` - Complete development configuration
- `detected_languages` - Programming languages detected
- `detected_frameworks` - Frameworks detected
- `testing_tools_detected` - Testing tools detected

### Deployment Patterns
- `deployment_strategies_detected` - Deployment strategies in use
- `ci_cd_tools` - CI/CD tools detected or configured
- `uses_gitops` - Whether GitOps practices are detected
- `uses_feature_flags` - Whether feature flags are in use
# Infrastructure Guidelines

## Modular Infrastructure Configuration

The infrastructure patterns have been reorganized into a dedicated module that provides:

### 1. Infrastructure as Code Detection
- Automatically identifies IaC tools from repository topics
- Configures tooling based on detected patterns
- Supports multiple IaC frameworks:
  - Terraform
  - CloudFormation
  - Pulumi
  - Ansible

### 2. Cloud Provider Integration
- Detects cloud providers from repository configuration
- Adapts guidelines based on provider requirements
- Supports major cloud platforms:
  - AWS
  - Azure
  - GCP
  - Alibaba Cloud

### 3. Kubernetes Configuration
- Identifies Kubernetes patterns
- Configures container orchestration
- Supports various distributions:
  - EKS
  - AKS
  - GKE
  - Self-managed K8s

### 4. Module Development Standards
- Enforces consistent module structure
- Manages documentation requirements
- Configures testing frameworks
- Handles versioning standards

## Example Infrastructure Setup

```hcl
module "cloud_platform" {
  source = "path/to/terraform-github-project"
  project_name = "cloud-platform"
  
  project_prompt = "Multi-cloud infrastructure platform with security focus"
  
  repositories = [
    {
      name = "terraform-modules"
      github_repo_topics = [
        "terraform-module",
        "infrastructure-module",
        "terratest",
        "terraform-docs"
      ]
      prompt = "Core infrastructure modules following best practices"
    },
    {
      name = "kubernetes-platform"
      github_repo_topics = [
        "kubernetes",
        "helm",
        "gitops",
        "argocd"
      ]
      prompt = "Kubernetes platform configuration and tools"
    }
  ]

  # New modular infrastructure configuration
  infrastructure_config = {
    iac_config = {
      iac_tools = ["terraform"]
      cloud_providers = ["aws", "azure"]
      documentation_tools = ["terraform-docs"]
      testing_frameworks = ["terratest"]
    }
  }

  # Related security configuration
  security_config = {
    enable_security_scanning = true
    security_frameworks = ["SOC2", "ISO27001"]
  }
}
```

## Module Integration

### Infrastructure Module
The dedicated infrastructure module handles:
- IaC tool configuration
- Cloud provider settings
- Kubernetes patterns
- Module development standards

### Related Modules
Infrastructure configuration integrates with:
1. Security Module
   - Infrastructure security patterns
   - Compliance requirements
   - Network security configuration

2. Development Module
   - Infrastructure CI/CD
   - GitOps practices
   - Deployment strategies

3. Quality Module
   - Infrastructure code quality
   - IaC linting
   - Documentation standards

## Best Practices

### Infrastructure as Code
- Use consistent formatting
- Document all variables and outputs
- Implement version constraints
- Secure state management
- Follow module standards

### Cloud Configuration
- Follow provider best practices
- Implement proper security controls
- Use recommended patterns
- Document provider-specific features

### Kubernetes Management
- Use proper namespacing
- Implement resource limits
- Configure health checks
- Apply security contexts
- Version control manifests

### Environment Management
- Separate environment configs
- Use environment variables
- Document procedures
- Include rollback plans
- Test infrastructure changes

## Testing

The infrastructure module includes comprehensive testing:
- Unit tests for module functionality
- Integration tests for cloud providers
- Validation for Kubernetes patterns
- Documentation verification
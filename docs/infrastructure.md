# Infrastructure Guidelines

## Smart Infrastructure Guidelines

The module analyzes your infrastructure configuration and creates smart guidelines for:

### 1. Infrastructure Tools
- Detects IaC tools like Terraform, CloudFormation, Ansible
- Identifies cloud providers from repository topics
- Recognizes Kubernetes and container patterns
- Adapts to your infrastructure testing tools

### 2. Compliance and Security
- Identifies required compliance frameworks (HIPAA, PCI, GDPR, etc.)
- Detects encryption and security requirements
- Analyzes audit logging patterns
- Recognizes backup and disaster recovery needs

### 3. Deployment Strategies
- Identifies deployment patterns (Blue-Green, Canary, GitOps)
- Detects CI/CD tooling preferences
- Recognizes feature flag usage
- Adapts to your release management approach

### 4. Module Development
- Detects module development patterns
- Identifies testing frameworks
- Recognizes documentation tools
- Provides module-specific guidelines

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
    },
    {
      name = "security-controls"
      github_repo_topics = [
        "terraform",
        "encryption",
        "audit",
        "hipaa",
        "pci"
      ]
      prompt = "Security and compliance controls"
    }
  ]
}
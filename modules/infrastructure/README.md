# Infrastructure Module

This module analyzes repository configurations to determine infrastructure patterns and module development practices. It helps standardize infrastructure as code practices and module development across repositories.

## Features

### Infrastructure as Code
- Detects IaC tools in use (Terraform, CloudFormation, etc.)
- Identifies cloud provider requirements
- Configures Kubernetes patterns
- Sets infrastructure testing standards

### Module Development
- Implements module documentation standards
- Configures testing frameworks
- Sets versioning requirements
- Manages module dependencies

## Usage

```hcl
module "infrastructure" {
  source = "./modules/infrastructure"

  repositories = [
    {
      name = "terraform-aws-vpc"
      github_repo_topics = [
        "terraform-module",
        "aws",
        "terratest",
        "terraform-docs"
      ]
      prompt = "AWS VPC Terraform module"
    }
  ]

  iac_config = {
    iac_tools = ["terraform"]
    cloud_providers = ["aws"]
    documentation_tools = ["terraform-docs"]
    testing_frameworks = ["terratest"]
  }
}
```

## Variables

### Required Variables
- `repositories` - List of repository configurations to analyze

### Optional Variables
- `iac_config` - Infrastructure as Code configuration including:
  - `iac_tools` - List of IaC tools to use
  - `cloud_providers` - List of cloud providers
  - `documentation_tools` - List of documentation tools
  - `testing_frameworks` - List of testing frameworks

## Outputs

### Infrastructure Configuration
- `infrastructure_config` - Complete infrastructure configuration
- `detected_iac_tools` - IaC tools detected from repository topics
- `detected_cloud_providers` - Cloud providers detected from topics
- `has_kubernetes` - Whether Kubernetes is used

### Module Configuration
- `uses_terraform_modules` - Whether Terraform modules are used
- `module_documentation_tools` - Documentation tools detected
- `module_testing_frameworks` - Testing frameworks detected
- `module_config` - Complete module configuration
[![Terraform Validation](https://github.com/HappyPathway/terraform-github-project/actions/workflows/terraform.yaml/badge.svg)](https://github.com/HappyPathway/terraform-github-project/actions/workflows/terraform.yaml)


[![Terraform Doc](https://github.com/HappyPathway/terraform-github-project/actions/workflows/terraform-doc.yaml/badge.svg)](https://github.com/HappyPathway/terraform-github-project/actions/workflows/terraform-doc.yaml)

# Terraform GitHub Project Module

This module helps you manage multiple GitHub repositories as a single project. It creates a main repository (master repo) and any other repositories you need for your project. It works well with GitHub Copilot for AI-assisted development.

## What This Module Does

- Creates a main repository and multiple project repositories
- Sets up GitHub Copilot to help write code for your project
- Creates smart coding guidelines based on your project setup
- Makes a VS Code workspace file that connects all your repositories
- Configures all your GitHub repository settings in one place
- Keeps repository names consistent by default

## Important Features

- **Smart AI Guidelines**: Automatically creates coding rules based on your project setup
- **Fixed Repository Names**: By default, repository names stay exactly as you set them
- **AI Help**: Sets up special files that help GitHub Copilot understand your project
- **Easy Setup**: Creates a workspace file that links all your repositories
- **Flexible Settings**: You can customize any GitHub repository setting

## How GitHub Copilot Helps

The module creates special files that help GitHub Copilot understand your code:
- Your main repository gets a `project-setup.prompt.md` file that explains the whole project
- Each repository gets a `repo-setup.prompt.md` file that explains that specific part
- A `copilot-instructions.md` file is created with smart coding rules based on your setup
- VS Code uses these files automatically when GitHub Copilot helps write code

The module can figure out good coding rules by looking at:
- How many parts your project has
- What each repository does
- Your security settings
- Your code review rules
- Your merge settings

## Smart AI Guidelines

The module analyzes your project configuration to create intelligent coding guidelines. Here's what it looks at:

### 1. Project Structure
- Number of repositories and their roles
- Organization membership
- Repository visibility settings
- Repository descriptions and topics

### 2. Code Review Standards
- Pull request requirements
- Required reviewer count
- Code owner requirements
- Review staleness rules
- Administrator overrides

### 3. Git Workflow
- Allowed merge types (merge, squash, rebase)
- Branch cleanup settings
- Default branch names
- Branch protection rules

### 4. Security Setup
- Repository visibility
- Vulnerability scanning
- Secret management
- Code scanning configurations

### 5. Collaboration Features
- Project board settings
- Wiki availability
- Issue tracking
- Documentation requirements

You can either:
- Let the module generate these guidelines automatically
- Provide your own with the `copilot_instructions` variable
- Or mix both by adding to the auto-generated guidelines

Example of auto-generated guidelines:
```hcl
module "my_project" {
  source = "path/to/terraform-github-project"
  project_name = "my-project"
  
  project_prompt = "This is a secure banking application"
  
  repositories = [
    {
      name = "frontend"
      github_is_private = true
      vulnerability_alerts = true
      security_and_analysis = {
        secret_scanning = {
          status = "enabled"
        }
      }
      # These settings will be detected and included in the guidelines
    }
  ]
}
```

This creates guidelines like:
- "Repositories are private by default"
- "Vulnerability scanning is enabled"
- "Secret scanning is configured"

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

### 6. Security Tooling
- Detects secret management solutions (Vault, AWS KMS, Azure Key Vault)
- Identifies cloud-specific security tools
- Recognizes certificate management tools
- Adapts to your security tooling preferences

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
```

This creates guidelines including:
- Infrastructure module development standards
- Kubernetes deployment practices
- Compliance requirements
- Security controls
- GitOps workflows

## Example Security Setup

```hcl
module "secure_platform" {
  source = "path/to/terraform-github-project"
  project_name = "secure-platform"
  
  project_prompt = "Security-focused platform with secret management"
  
  repositories = [
    {
      name = "vault-config"
      github_repo_topics = [
        "vault",
        "hashicorp-vault",
        "vault-agent",
        "opa"
      ]
      prompt = "HashiCorp Vault configuration and policies"
    },
    {
      name = "cloud-secrets"
      github_repo_topics = [
        "aws-kms",
        "azure-key-vault",
        "external-secrets",
        "sealed-secrets"
      ]
      prompt = "Cloud key management and secret handling"
    },
    {
      name = "security-scanning"
      github_repo_topics = [
        "snyk",
        "trivy",
        "security-scanning",
        "vulnerability-management"
      ]
      prompt = "Security scanning and vulnerability management"
    }
  ]
}
```

This creates guidelines including:
- Vault configuration standards
- Cloud key management practices
- Secret rotation policies
- Security scanning requirements
- Audit logging requirements

## Example Zero Trust Security Setup

```hcl
module "zero_trust_platform" {
  source = "path/to/terraform-github-project"
  project_name = "zero-trust-platform"
  
  project_prompt = "Zero Trust security platform with network segmentation"
  
  repositories = [
    {
      name = "service-mesh"
      github_repo_topics = [
        "istio",
        "zero-trust",
        "mTLS",
        "service-mesh"
      ]
      prompt = "Service mesh configuration with zero trust principles"
    },
    {
      name = "network-policies"
      github_repo_topics = [
        "network-policy",
        "cilium",
        "security-groups",
        "waf"
      ]
      prompt = "Network policies and security configurations"
    },
    {
      name = "identity-provider"
      github_repo_topics = [
        "vault",
        "opa",
        "authentication",
        "authorization"
      ]
      prompt = "Identity and access management services"
    }
  ]
}
```

This creates guidelines including:
- Zero Trust architecture principles
- Service mesh security configurations
- Network policy standards
- Identity-based access controls
- Security monitoring requirements

## Security Analysis Features

The module automatically detects and provides guidelines for:

### 1. Secret Management
- HashiCorp Vault integration
- Cloud KMS (AWS, Azure, GCP)
- Certificate management
- Key rotation policies

### 2. Compliance Frameworks
- SOC2, ISO27001, HIPAA, GDPR
- Audit requirements
- Security controls
- Documentation standards

### 3. Container Security
- Image scanning tools
- Runtime protection
- Registry security
- Base image standards

### 4. Network Security
- Zero Trust architecture
- Service mesh security
- Network policies
- Traffic monitoring

### 5. Security Scanning
- SAST/DAST tools
- Dependency scanning
- Compliance checking
- Vulnerability reporting

## How to Use It

Here's a simple example:

```hcl
module "my_project" {
  source = "path/to/terraform-github-project"
  project_name = "my-awesome-project"
  
  # Tell GitHub Copilot about your project
  project_prompt = <<-EOT
    This project is a simple web app with:
    - A frontend that shows data
    - An API that handles requests
    - A database that stores information
  EOT

  # Optional: Provide custom coding rules
  copilot_instructions = <<-EOT
    When writing code for this project:
    1. Use TypeScript for all code
    2. Write tests for all features
    3. Follow our security guidelines
  EOT

  # Set up your repositories
  repositories = [
    {
      name = "frontend"
      prompt = <<-EOT
        This is the frontend website.
        - Uses React
        - Shows user data
        - Looks nice and works well
      EOT
      github_repo_description = "Frontend website"
      github_repo_topics = ["react", "frontend"]
      github_is_private = false
    },
    {
      name = "api"
      prompt = <<-EOT
        This is the API service.
        - Handles data requests
        - Connects to the database
        - Keeps data safe
      EOT
      github_repo_description = "API service"
      github_repo_topics = ["api", "backend"]
      github_is_private = false
    }
  ]

  # Add extra folders to your workspace
  workspace_files = [
    {
      name = "docs"
      path = "./docs"
    }
  ]
}
```

## Settings You Can Change

| Name | What It Does | Type | Required? | Default |
|------|--------------|------|-----------|---------|
| project_name | The name of your project | string | Yes | - |
| project_prompt | Instructions for GitHub Copilot about your whole project | string | Yes | - |
| copilot_instructions | Custom coding rules for GitHub Copilot | string | No | Auto-generated from project setup |
| repositories | List of repositories to create | list(object) | Yes | - |
| workspace_files | Extra files to include in your workspace | list(object) | No | [] |
| enforce_prs | Require pull request reviews for all repositories | bool | No | true |

Each repository in your `repositories` list can have these settings:
- All standard GitHub repository settings
- A `prompt` field to help GitHub Copilot understand the repository
- `force_name` is true by default (keeps the exact name you choose)

## What You Get Back (Outputs)

| Name | What It Tells You |
|------|------------------|
| master_repo | Information about your main repository |
| project_repos | Information about all your project repositories |
| workspace_file_path | Where to find the VS Code workspace file |
| copilot_prompts | Where to find the GitHub Copilot instruction files |

## VS Code Setup

The module creates a `.code-workspace` file in your main repository that:
- Connects all your project repositories
- Makes it easy to switch between repositories
- Helps GitHub Copilot understand your whole project

## Important Notes

- The module can create smart coding rules by looking at your project setup
- You can provide your own coding rules using `copilot_instructions`
- The prompts are for GitHub Copilot to write better code, not just for documentation
- Each repository's prompt should explain what that specific repository does
- The main repository's prompt should explain how everything works together
- Repository names stay exactly as you set them (no automatic changes)

<!-- BEGIN_TF_DOCS -->
{{ .Content }}
<!-- END_TF_DOCS -->
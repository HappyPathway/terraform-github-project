# Terraform GitHub Project Module

[![Terraform Validation](https://github.com/HappyPathway/terraform-github-project/actions/workflows/terraform.yaml/badge.svg)](https://github.com/HappyPathway/terraform-github-project/actions/workflows/terraform.yaml)

[![Terraform Doc](https://github.com/HappyPathway/terraform-github-project/actions/workflows/terraform-doc.yaml/badge.svg)](https://github.com/HappyPathway/terraform-github-project/actions/workflows/terraform-doc.yaml)

![Terraform GitHub Project Overview](terraform-github-project.png)

## GitHub Free Tier Compatibility

This module is designed to work seamlessly with GitHub Free accounts by default:

- All repositories are created as public by default
- Branch protection is automatically enabled for public repositories
- Private repositories automatically disable branch protection (GitHub Free limitation)
- Clear warnings are provided when using features requiring GitHub Pro
- Easy upgrade path to GitHub Pro when needed

### Visibility and Feature Matrix

| Feature                  | Public Repo | Private Repo (Free) | Private Repo (Pro) |
|-------------------------|-------------|-------------------|------------------|
| Branch Protection       | ✅          | ❌                | ✅               |
| Required Reviews        | ✅          | ❌                | ✅               |
| Code Owners            | ✅          | ❌                | ✅               |
| Advanced Security      | Limited     | Limited           | ✅               |

### Working with Private Repositories

If you need private repositories with GitHub Free:
1. Set `visibility = "private"` for the repository
2. Branch protection will be automatically disabled
3. A warning file will be added to the repository
4. Consider upgrading to GitHub Pro if you need advanced features

## Quick Start Guide
This module is designed to help you instantly scaffold entire GitHub project workspaces that are GitHub Copilot-ready. With just one Terraform configuration, you can:

1. Create a main repository and all your project repositories
2. Generate a VS Code workspace that links everything together
3. Set up custom prompt files that help GitHub Copilot understand your entire project architecture
4. Pre-seed repositories with `.copilot-instructions.md` files containing project-specific coding guidelines

The real power comes when you open the workspace in VS Code - GitHub Copilot immediately understands your entire project structure and can help generate code across all repositories following your project's standards.

For example, you can tell Copilot "implement the API endpoints described in the project prompt" and it will understand the context from your prompt files and generate code following your project's patterns.

## What This Module Does

- Creates or manages a main repository and multiple project repositories
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

## Example: Managing Existing Repositories

```hcl
module "existing_project" {
  source = "path/to/terraform-github-project"
  project_name = "existing-project"
  
  project_prompt = "Managing existing repositories in our organization"
  
  repositories = [
    {
      name = "existing-repo-1"
      create_repo = false  # This tells Terraform to manage an existing repository
      prompt = "First existing repository"
      github_repo_description = "Managing an existing repository"
      github_repo_topics = ["existing", "managed"]
    },
    {
      name = "existing-repo-2"
      create_repo = false
      prompt = "Second existing repository"
      github_repo_topics = ["existing", "managed"]
    }
  ]
}
```

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
| repositories | List of repositories to create or manage | list(object) | Yes | - |
| workspace_files | Extra files to include in your workspace | list(object) | No | [] |
| enforce_prs | Require pull request reviews for all repositories | bool | No | true |

Each repository in your `repositories` list can have these settings:
- `name` - Name of the repository (required)
- `create_repo` - Whether to create a new repository or manage an existing one (default: true)
- `prompt` - Help GitHub Copilot understand the repository
- All standard GitHub repository settings
- `force_name` is true by default (keeps the exact name you choose)

## What You Get Back (Outputs)

| Name | What It Tells You |
|------|------------------|
| master_repo | All attributes of your main repository (name, URLs, settings, etc.) |
| project_repos | All attributes of your project repositories |
| workspace_file_path | Where to find the VS Code workspace file |
| copilot_prompts | Where to find the GitHub Copilot instruction files |
| repository_urls | Easy access to all repository URLs (HTML, SSH, HTTP, Git) |
| security_status | Security settings status for all repositories |

### Repository Attributes Available in Outputs

For each repository (both master and project repos), you get:

Basic Info:
- name - Repository name
- full_name - Full repository name (org/repo)
- description - Repository description
- html_url - GitHub web URL
- ssh_url - SSH clone URL
- http_url - HTTPS clone URL
- git_url - Git protocol URL
- visibility - Public or private status

Settings:
- topics - Repository topics
- has_issues - Issue tracking enabled
- has_projects - Project boards enabled
- has_wiki - Wiki enabled
- is_template - Template repository status
- allow_merge_commit - Merge commit allowed
- allow_squash_merge - Squash merge allowed
- allow_rebase_merge - Rebase merge allowed
- allow_auto_merge - Auto-merge enabled
- delete_branch_on_merge - Branch deletion on merge

Additional Info:
- default_branch - Default branch name
- archived - Archive status
- homepage_url - Homepage URL if set
- vulnerability_alerts - Vulnerability alerts status
- template - Template repository details if used
- gitignore_template - .gitignore template if used
- license_template - License template if used

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
## Requirements

No requirements.

## Providers

| Name | Version |
|------|---------|
| <a name="provider_github"></a> [github](#provider\_github) | 6.5.0 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_base_repo"></a> [base\_repo](#module\_base\_repo) | HappyPathway/repo/github | n/a |
| <a name="module_project_repos"></a> [project\_repos](#module\_project\_repos) | HappyPathway/repo/github | n/a |

## Resources

| Name | Type |
|------|------|
| [github_branch_protection.base_repo](https://registry.terraform.io/providers/hashicorp/github/latest/docs/resources/branch_protection) | resource |
| [github_repository_file.base_repo_codeowners](https://registry.terraform.io/providers/hashicorp/github/latest/docs/resources/repository_file) | resource |
| [github_repository_file.base_repo_files](https://registry.terraform.io/providers/hashicorp/github/latest/docs/resources/repository_file) | resource |
| [github_repository_file.project_files](https://registry.terraform.io/providers/hashicorp/github/latest/docs/resources/repository_file) | resource |
| [github_organization.org](https://registry.terraform.io/providers/hashicorp/github/latest/docs/data-sources/organization) | data source |
| [github_repository.existing_lookup](https://registry.terraform.io/providers/hashicorp/github/latest/docs/data-sources/repository) | data source |
| [github_repository.existing_repos](https://registry.terraform.io/providers/hashicorp/github/latest/docs/data-sources/repository) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_base_repository"></a> [base\_repository](#input\_base\_repository) | Configuration for the base repository. This repository serves as the foundation for the project and contains shared configurations. | <pre>object({<br>    # Core settings<br>    description            = optional(string)<br>    homepage_url           = optional(string)<br>    topics                 = optional(list(string), ["project-base"])<br>    visibility             = optional(string, "private")<br>    has_issues            = optional(bool, true)<br>    has_wiki              = optional(bool, true)<br>    has_projects          = optional(bool, true)<br>    has_discussions       = optional(bool, false)<br>    has_downloads         = optional(bool, false)<br>    <br>    # Git settings<br>    default_branch         = optional(string, "main")<br>    allow_merge_commit     = optional(bool, false)<br>    allow_squash_merge     = optional(bool, true)<br>    allow_rebase_merge     = optional(bool, false)<br>    allow_auto_merge      = optional(bool, false)<br>    delete_branch_on_merge = optional(bool, true)<br>    allow_update_branch   = optional(bool, true)<br>    merge_commit_title    = optional(string, "MERGE_MESSAGE")<br>    merge_commit_message  = optional(string, "PR_TITLE")<br>    squash_merge_commit_title = optional(string, "COMMIT_OR_PR_TITLE")<br>    squash_merge_commit_message = optional(string, "COMMIT_MESSAGES")<br>    <br>    # Security settings<br>    vulnerability_alerts   = optional(bool, true)<br>    security_and_analysis = optional(object({<br>      advanced_security = optional(object({<br>        status = string<br>      }))<br>      secret_scanning = optional(object({<br>        status = string<br>      }))<br>      secret_scanning_push_protection = optional(object({<br>        status = string<br>      }))<br>    }))<br>    require_signed_commits = optional(bool, false)<br>    <br>    # Protection settings<br>    enable_branch_protection = optional(bool, true)<br>    enforce_prs             = optional(bool, true)<br>    branch_protection = optional(object({<br>      enforce_admins                = optional(bool, true)<br>      required_linear_history      = optional(bool, true)<br>      allow_force_pushes           = optional(bool, false)<br>      allow_deletions             = optional(bool, false)<br>      require_conversation_resolution = optional(bool, true)<br>      required_approving_review_count = optional(number, 1)<br>      dismiss_stale_reviews        = optional(bool, true)<br>      require_code_owner_reviews   = optional(bool, true)<br>      required_status_checks      = optional(object({<br>        strict = optional(bool, true)<br>        contexts = optional(list(string), [])<br>      }))<br>    }))<br>    pull_request_bypassers = optional(list(string), [])<br>    <br>    # File management<br>    gitignore_template     = optional(string)<br>    license_template       = optional(string)<br>    codeowners            = optional(list(string), [])<br>    create_codeowners     = optional(bool, true)<br>    extra_files           = optional(list(object({<br>      path    = string<br>      content = string<br>    })), [])<br>    managed_extra_files   = optional(list(object({<br>      path    = string<br>      content = string<br>    })))<br>    allow_unsigned_files  = optional(bool, false)<br>    commit_author        = optional(string, "Terraform")<br>    commit_email         = optional(string, "terraform@example.com")<br>    <br>    # Access control<br>    admin_teams           = optional(list(string), [])<br>    push_teams            = optional(list(string), [])<br>    maintain_teams        = optional(list(string), [])<br>    pull_teams            = optional(list(string), [])<br>    triage_teams          = optional(list(string), [])<br>    collaborators         = optional(map(string), {})<br>    github_org_teams      = optional(list(any))<br>    <br>    # Additional settings<br>    template = optional(object({<br>      owner = string<br>      repository = string<br>    }))<br>    pages = optional(object({<br>      branch = string<br>      path = optional(string, "/")<br>      cname = optional(string)<br>    }))<br>    archived              = optional(bool, false)<br>    archive_on_destroy    = optional(bool, true)<br>    create_repo           = optional(bool, true)<br>    prefix               = optional(string)<br>    force_name           = optional(bool, false)<br>    is_template          = optional(bool, false)<br>  })</pre> | `{}` | no |
| <a name="input_copilot_instructions"></a> [copilot\_instructions](#input\_copilot\_instructions) | Custom Copilot instructions. If not provided, generated instructions will be used. | `string` | `null` | no |
| <a name="input_default_branch"></a> [default\_branch](#input\_default\_branch) | The default branch name for all repositories | `string` | `"main"` | no |
| <a name="input_enforce_prs"></a> [enforce\_prs](#input\_enforce\_prs) | Whether to enforce pull request reviews across all repositories | `bool` | `true` | no |
| <a name="input_environments"></a> [environments](#input\_environments) | Configuration for GitHub environments in each repository | <pre>map(list(object({<br>    name = string<br>    reviewers = optional(object({<br>      teams = optional(list(string), [])<br>      users = optional(list(string), [])<br>    }), {})<br>    deployment_branch_policy = optional(object({<br>      protected_branches     = optional(bool, true)<br>      custom_branch_policies = optional(bool, false)<br>    }), {})<br>    secrets = optional(list(object({<br>      name  = string<br>      value = string<br>    })), [])<br>    vars = optional(list(object({<br>      name  = string<br>      value = string<br>    })), [])<br>  })))</pre> | `{}` | no |
| <a name="input_initialization_script"></a> [initialization\_script](#input\_initialization\_script) | Optional custom initialization script to be appended to the default git clone commands | <pre>object({<br>    name    = string<br>    content = string<br>  })</pre> | `null` | no |
| <a name="input_project_name"></a> [project\_name](#input\_project\_name) | Name of the project. Will be used as the base repository name. | `string` | n/a | yes |
| <a name="input_project_prompt"></a> [project\_prompt](#input\_project\_prompt) | Content for the project's prompt file | `string` | n/a | yes |
| <a name="input_repo_org"></a> [repo\_org](#input\_repo\_org) | GitHub organization name | `string` | n/a | yes |
| <a name="input_repositories"></a> [repositories](#input\_repositories) | List of project repositories to create/manage | <pre>list(object({<br>    name = string<br>    repo_org = optional(string)<br>    create_repo = optional(bool, true)<br>    github_repo_description = optional(string)<br>    github_repo_topics = optional(list(string), [])<br>    github_push_restrictions = optional(list(string), [])<br>    github_is_private = optional(bool, true)<br>    github_auto_init = optional(bool, true)<br>    github_allow_merge_commit = optional(bool, false)<br>    github_allow_squash_merge = optional(bool, true)<br>    github_allow_rebase_merge = optional(bool, false)<br>    github_delete_branch_on_merge = optional(bool, true)<br>    github_has_projects = optional(bool, true)<br>    github_has_issues = optional(bool, false)<br>    github_has_wiki = optional(bool, true)<br>    github_default_branch = optional(string, "main")<br>    github_required_approving_review_count = optional(number, 1)<br>    github_require_code_owner_reviews = optional(bool, true)<br>    github_dismiss_stale_reviews = optional(bool, true)<br>    github_enforce_admins_branch_protection = optional(bool, true)<br>    additional_codeowners = optional(list(string), [])<br>    prefix = optional(string)<br>    force_name = optional(bool, false)<br>    github_org_teams = optional(list(any))<br>    template_repo_org = optional(string)<br>    template_repo = optional(string)<br>    is_template = optional(bool, false)<br>    admin_teams = optional(list(string), [])<br>    required_status_checks = optional(object({<br>      contexts = list(string)<br>      strict = optional(bool, false)<br>    }))<br>    archived = optional(bool, false)<br>    secrets = optional(list(object({<br>      name = string<br>      value = string<br>    })), [])<br>    vars = optional(list(object({<br>      name = string<br>      value = string<br>    })), [])<br>    extra_files = optional(list(object({<br>      path = string<br>      content = string<br>    })), [])<br>    managed_extra_files = optional(list(object({<br>      path = string<br>      content = string<br>    })))<br>    pull_request_bypassers = optional(list(string), [])<br>    create_codeowners = optional(bool, true)<br>    enforce_prs = optional(bool, true)<br>    collaborators = optional(map(string), {})<br>    archive_on_destroy = optional(bool, true)<br>    vulnerability_alerts = optional(bool, false)<br>    gitignore_template = optional(string)<br>    homepage_url = optional(string)<br>    security_and_analysis = optional(object({<br>      advanced_security = optional(object({<br>        status = string<br>      }))<br>      secret_scanning = optional(object({<br>        status = string<br>      }))<br>      secret_scanning_push_protection = optional(object({<br>        status = string<br>      }))<br>    }))<br>    prompt = string<br>  }))</pre> | `[]` | no |
| <a name="input_workspace_files"></a> [workspace\_files](#input\_workspace\_files) | Additional files to include in the VS Code workspace configuration | <pre>list(object({<br>    name = string<br>    path = string<br>  }))</pre> | `[]` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_all_repos"></a> [all\_repos](#output\_all\_repos) | Combined map of all repositories including master repo |
| <a name="output_base_repo"></a> [base\_repo](#output\_base\_repo) | All attributes of the master repository |
| <a name="output_base_repository"></a> [base\_repository](#output\_base\_repository) | All attributes of the base repository |
| <a name="output_base_repository_files"></a> [base\_repository\_files](#output\_base\_repository\_files) | Files created in the base repository |
| <a name="output_copilot_prompts"></a> [copilot\_prompts](#output\_copilot\_prompts) | Paths to the GitHub Copilot prompt files for each repository |
| <a name="output_project_repos"></a> [project\_repos](#output\_project\_repos) | Map of all project repositories and their attributes |
| <a name="output_repositories"></a> [repositories](#output\_repositories) | All project repositories |
| <a name="output_repository_urls"></a> [repository\_urls](#output\_repository\_urls) | Map of repository names to their various URLs |
| <a name="output_security_status"></a> [security\_status](#output\_security\_status) | Security configuration status for all repositories |
| <a name="output_workspace_file_path"></a> [workspace\_file\_path](#output\_workspace\_file\_path) | Path to the generated VS Code workspace file |
<!-- END_TF_DOCS -->

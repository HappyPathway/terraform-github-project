# Terraform GitHub Project

A Terraform module for managing GitHub projects with standardized configurations for security, development, infrastructure, and code quality.

## New Modular Structure

The module has been reorganized into focused submodules to improve maintainability and testing:

```
modules/
  ├── security/          # Security and compliance configuration
  ├── development/       # Development standards and deployment
  ├── infrastructure/    # Infrastructure patterns and IaC
  └── quality/          # Code quality and standards
```

## Migration Guide

### For Existing Users

If you're using version 1.x, follow these steps to migrate:

1. Update your module source to reference version 2.0
2. Review the module-specific documentation:
   - [Security Module](modules/security/README.md)
   - [Development Module](modules/development/README.md)
   - [Infrastructure Module](modules/infrastructure/README.md)
   - [Quality Module](modules/quality/README.md)
3. Update your module configuration according to the new structure

### Breaking Changes

- Local variables have been moved to their respective modules
- Some variable names have been standardized across modules
- Configuration structure has been modularized

### Example Migration

Before:
```hcl
module "github_project" {
  source = "path/to/module"

  repositories = [
    {
      name = "app"
      github_repo_topics = ["docker", "terraform"]
    }
  ]
}
```

After:
```hcl
module "github_project" {
  source = "path/to/module"

  repositories = [
    {
      name = "app"
      github_repo_topics = ["docker", "terraform"]
    }
  ]

  # New modular configuration
  security_config = {
    enable_security_scanning = true
    container_security_config = {
      scanning_tools = ["trivy"]
    }
  }

  development_config = {
    testing_requirements = {
      required = true
    }
  }

  infrastructure_config = {
    iac_tools = ["terraform"]
  }

  quality_config = {
    linting_required = true
  }
}
```

## Modules

### Security Module
Manages security configurations including:
- Container security
- Network security
- Compliance requirements

### Development Module
Handles development standards including:
- Programming languages and frameworks
- Testing requirements
- Deployment patterns

### Infrastructure Module
Manages infrastructure patterns including:
- IaC tool configuration
- Cloud provider settings
- Module development standards

### Quality Module
Enforces code quality standards including:
- Linting requirements
- Type safety
- Documentation standards

## Testing

Each module includes its own test suite:
```
tests/
  ├── security/
  ├── development/
  ├── infrastructure/
  └── quality/
```

Run tests with:
```bash
terraform test
```

## Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md) for development guidelines.

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

[![Terraform Validation](https://github.com/HappyPathway/terraform-github-project/actions/workflows/terraform.yaml/badge.svg)](https://github.com/HappyPathway/terraform-github-project/actions/workflows/terraform.yaml)
[![Terraform Doc](https://github.com/HappyPathway/terraform-github-project/actions/workflows/terraform-doc.yaml/badge.svg)](https://github.com/HappyPathway/terraform-github-project/actions/workflows/terraform-doc.yaml)

![Project Architecture](terraform-github-project.png)

This module helps you manage GitHub projects with multiple repositories and consistent development environments.

## Documentation

- [Quick Start Guide](docs/quickstart.md) - Get started with basic usage
- [Features Overview](docs/features.md) - Development environment features and capabilities
- [GitHub Copilot Integration](docs/copilot.md) - How the module integrates with GitHub Copilot
- [Security Features](docs/security.md) - Security analysis and configuration options
- [Infrastructure Guidelines](docs/infrastructure.md) - Smart infrastructure management
- [Managing Existing Repos](docs/existing-repos.md) - How to manage existing repositories

## Configuration Reference

Below is the complete configuration reference for this module. For detailed examples and use cases, please refer to the documentation links above.

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_github"></a> [github](#requirement\_github) | ~> 6.2 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_github"></a> [github](#provider\_github) | 6.5.0 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_base_repo"></a> [base\_repo](#module\_base\_repo) | HappyPathway/repo/github | 1.0.67 |
| <a name="module_base_repository_files"></a> [base\_repository\_files](#module\_base\_repository\_files) | ./modules/repository_files | n/a |
| <a name="module_copilot"></a> [copilot](#module\_copilot) | ./modules/copilot | n/a |
| <a name="module_development"></a> [development](#module\_development) | ./modules/development | n/a |
| <a name="module_development_environment"></a> [development\_environment](#module\_development\_environment) | ./modules/development_environment | n/a |
| <a name="module_infrastructure"></a> [infrastructure](#module\_infrastructure) | ./modules/infrastructure | n/a |
| <a name="module_project_repos"></a> [project\_repos](#module\_project\_repos) | HappyPathway/repo/github | n/a |
| <a name="module_project_repository_files"></a> [project\_repository\_files](#module\_project\_repository\_files) | ./modules/repository_files | n/a |
| <a name="module_quality"></a> [quality](#module\_quality) | ./modules/quality | n/a |
| <a name="module_security"></a> [security](#module\_security) | ./modules/security | n/a |

## Resources

| Name | Type |
|------|------|
| [github_branch_protection.base_repo](https://registry.terraform.io/providers/integrations/github/latest/docs/resources/branch_protection) | resource |
| [github_branch_protection.project_repos](https://registry.terraform.io/providers/integrations/github/latest/docs/resources/branch_protection) | resource |
| [github_organization.org](https://registry.terraform.io/providers/integrations/github/latest/docs/data-sources/organization) | data source |
| [github_repository.existing_lookup](https://registry.terraform.io/providers/integrations/github/latest/docs/data-sources/repository) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_archive_on_destroy"></a> [archive\_on\_destroy](#input\_archive\_on\_destroy) | Archive repositories on destroy | `bool` | `true` | no |
| <a name="input_base_repository"></a> [base\_repository](#input\_base\_repository) | Configuration for the base repository. This repository serves as the foundation for the project and contains shared configurations. | <pre>object({<br>    # Core settings<br>    description     = optional(string)<br>    homepage_url    = optional(string)<br>    topics          = optional(list(string), ["project-base"])<br>    visibility      = optional(string, "private")<br>    has_issues      = optional(bool, true)<br>    has_wiki        = optional(bool, true)<br>    has_projects    = optional(bool, true)<br>    has_discussions = optional(bool, false)<br>    has_downloads   = optional(bool, false)<br><br>    # Git settings<br>    default_branch              = optional(string, "main")<br>    allow_merge_commit          = optional(bool, false)<br>    allow_squash_merge          = optional(bool, true)<br>    allow_rebase_merge          = optional(bool, false)<br>    allow_auto_merge            = optional(bool, false)<br>    delete_branch_on_merge      = optional(bool, true)<br>    allow_update_branch         = optional(bool, true)<br>    merge_commit_title          = optional(string, "MERGE_MESSAGE")<br>    merge_commit_message        = optional(string, "PR_TITLE")<br>    squash_merge_commit_title   = optional(string, "COMMIT_OR_PR_TITLE")<br>    squash_merge_commit_message = optional(string, "COMMIT_MESSAGES")<br><br>    # Security settings<br>    vulnerability_alerts = optional(bool, true)<br>    security_and_analysis = optional(object({<br>      advanced_security = optional(object({<br>        status = string<br>      }))<br>      secret_scanning = optional(object({<br>        status = string<br>      }))<br>      secret_scanning_push_protection = optional(object({<br>        status = string<br>      }))<br>    }))<br>    require_signed_commits = optional(bool, false)<br><br>    # Protection settings<br>    enable_branch_protection = optional(bool, false)<br>    enforce_prs              = optional(bool, false)<br>    branch_protection = optional(object({<br>      enforce_admins                  = optional(bool, true)<br>      required_linear_history         = optional(bool, true)<br>      allow_force_pushes              = optional(bool, false)<br>      allow_deletions                 = optional(bool, false)<br>      require_conversation_resolution = optional(bool, true)<br>      required_approving_review_count = optional(number, 1)<br>      dismiss_stale_reviews           = optional(bool, true)<br>      require_code_owner_reviews      = optional(bool, true)<br>      required_status_checks = optional(object({<br>        strict   = optional(bool, true)<br>        contexts = optional(list(string), [])<br>      }))<br>    }))<br>    pull_request_bypassers = optional(list(string), [])<br><br>    # File management<br>    gitignore_template = optional(string)<br>    license_template   = optional(string)<br>    codeowners         = optional(list(string), [])<br>    create_codeowners  = optional(bool, true)<br>    extra_files = optional(list(object({<br>      path    = string<br>      content = string<br>    })), [])<br>    managed_extra_files = optional(list(object({<br>      path    = string<br>      content = string<br>    })))<br>    allow_unsigned_files = optional(bool, false)<br>    commit_author        = optional(string, "Terraform")<br>    commit_email         = optional(string, "terraform@roknsound.com")<br><br>    # Access control<br>    admin_teams      = optional(list(string), [])<br>    push_teams       = optional(list(string), [])<br>    maintain_teams   = optional(list(string), [])<br>    pull_teams       = optional(list(string), [])<br>    triage_teams     = optional(list(string), [])<br>    collaborators    = optional(map(string), {})<br>    github_org_teams = optional(list(any))<br><br>    # Additional settings<br>    template = optional(object({<br>      owner      = string<br>      repository = string<br>    }))<br>    pages = optional(object({<br>      branch = string<br>      path   = optional(string, "/")<br>      cname  = optional(string)<br>    }))<br>    archived           = optional(bool, false)<br>    archive_on_destroy = optional(bool, true)<br>    create_repo        = optional(bool, true)<br>    prefix             = optional(string)<br>    force_name         = optional(bool, false)<br>    is_template        = optional(bool, false)<br>  })</pre> | `{}` | no |
| <a name="input_codespaces"></a> [codespaces](#input\_codespaces) | Configuration for GitHub Codespaces | <pre>object({<br>    machine_type        = optional(string, "medium")<br>    retention_days      = optional(number, 30)<br>    prebuild_enabled    = optional(bool, false)<br>    env_vars            = optional(map(string), {})<br>    secrets             = optional(list(string), [])<br>    dotfiles_repository = optional(string)<br>    custom_image        = optional(string)<br>  })</pre> | `null` | no |
| <a name="input_copilot_instructions"></a> [copilot\_instructions](#input\_copilot\_instructions) | Custom Copilot instructions. If not provided, generated instructions will be used. | `string` | `null` | no |
| <a name="input_default_branch"></a> [default\_branch](#input\_default\_branch) | The default branch name for all repositories | `string` | `"main"` | no |
| <a name="input_development_config"></a> [development\_config](#input\_development\_config) | Configuration for development module including standards and deployment patterns | <pre>object({<br>    testing_requirements = optional(object({<br>      required           = optional(bool, true)<br>      coverage_threshold = optional(number, 80)<br>    }), {})<br>    ci_cd_config = optional(object({<br>      ci_cd_tools            = optional(list(string), [])<br>      required_status_checks = optional(list(string), [])<br>    }), {})<br>  })</pre> | `{}` | no |
| <a name="input_development_container"></a> [development\_container](#input\_development\_container) | Configuration for development containers across repositories | <pre>object({<br>    base_image           = string<br>    install_tools        = optional(list(string), [])<br>    vs_code_extensions   = optional(list(string), [])<br>    env_vars             = optional(map(string), {})<br>    ports                = optional(list(string), [])<br>    post_create_commands = optional(list(string), [])<br>    docker_compose = optional(object({<br>      enabled = bool<br>      services = map(object({<br>        image       = string<br>        ports       = list(string)<br>        environment = map(string)<br>      }))<br>    }))<br>  })</pre> | `null` | no |
| <a name="input_docs_base_path"></a> [docs\_base\_path](#input\_docs\_base\_path) | Base path where documentation repositories will be cloned. Supports environment variables (VAR) and shell expansion (~) | `string` | `"${userHome}/.gproj/docs"` | no |
| <a name="input_documentation_sources"></a> [documentation\_sources](#input\_documentation\_sources) | List of external repositories to clone as documentation/reference sources | <pre>list(object({<br>    repo = string                   # GitHub repository URL to clone<br>    name = string                   # Name to use in workspace file<br>    path = optional(string, ".")    # Optional, defaults to "." for top-level<br>    tag  = optional(string, "main") # Optional, defaults to main<br>  }))</pre> | `[]` | no |
| <a name="input_enforce_prs"></a> [enforce\_prs](#input\_enforce\_prs) | Whether to enforce pull request reviews across all repositories | `bool` | `true` | no |
| <a name="input_environments"></a> [environments](#input\_environments) | Configuration for GitHub environments in each repository | <pre>map(list(object({<br>    name = string<br>    reviewers = optional(object({<br>      teams = optional(list(string), [])<br>      users = optional(list(string), [])<br>    }), {})<br>    deployment_branch_policy = optional(object({<br>      protected_branches     = optional(bool, true)<br>      custom_branch_policies = optional(bool, false)<br>    }), {})<br>    secrets = optional(list(object({<br>      name  = string<br>      value = string<br>    })), [])<br>    vars = optional(list(object({<br>      name  = string<br>      value = string<br>    })), [])<br>  })))</pre> | `{}` | no |
| <a name="input_github_pro_enabled"></a> [github\_pro\_enabled](#input\_github\_pro\_enabled) | Set to true if you have GitHub Pro subscription. Some features like branch protection on private repositories require GitHub Pro. | `bool` | `false` | no |
| <a name="input_infrastructure_config"></a> [infrastructure\_config](#input\_infrastructure\_config) | Configuration for infrastructure module including IaC and cloud providers | <pre>object({<br>    iac_config = optional(object({<br>      iac_tools           = optional(list(string), [])<br>      cloud_providers     = optional(list(string), [])<br>      documentation_tools = optional(list(string), ["terraform-docs"])<br>      testing_frameworks  = optional(list(string), [])<br>    }), {})<br>  })</pre> | `{}` | no |
| <a name="input_initialization_script"></a> [initialization\_script](#input\_initialization\_script) | Optional custom initialization script to be appended to the default git clone commands | <pre>object({<br>    name    = string<br>    content = string<br>  })</pre> | `null` | no |
| <a name="input_mkfiles"></a> [mkfiles](#input\_mkfiles) | Whether to create repository files. Set to false for initial repo creation, then true to create files. | `bool` | `false` | no |
| <a name="input_project_name"></a> [project\_name](#input\_project\_name) | Name of the project. Will be used as the base repository name. | `string` | n/a | yes |
| <a name="input_project_owners"></a> [project\_owners](#input\_project\_owners) | List of GitHub usernames that are owners of the project | `list(string)` | `[]` | no |
| <a name="input_project_prompt"></a> [project\_prompt](#input\_project\_prompt) | Content for the project's prompt file | `string` | n/a | yes |
| <a name="input_quality_config"></a> [quality\_config](#input\_quality\_config) | Configuration for code quality module including linting and documentation requirements | <pre>object({<br>    enable_code_scanning   = optional(bool, true)<br>    code_quality_tools     = optional(list(string), [])<br>    linting_required       = optional(bool, true)<br>    type_safety            = optional(bool, true)<br>    documentation_required = optional(bool, true)<br>    formatting_tools       = optional(list(string), [])<br>    linting_tools          = optional(list(string), [])<br>    documentation_tools    = optional(list(string), [])<br>  })</pre> | `{}` | no |
| <a name="input_repo_org"></a> [repo\_org](#input\_repo\_org) | GitHub organization name | `string` | n/a | yes |
| <a name="input_repositories"></a> [repositories](#input\_repositories) | List of repositories to include in the workspace. | <pre>list(object({<br>    name                 = string<br>    prompt               = string<br>    topics               = optional(list(string), [])<br>    create_repo          = optional(bool, true)<br>    vulnerability_alerts = optional(bool, true)<br>    enforce_prs          = optional(bool, true)<br>    default_branch       = optional(string, "main")<br>    security_and_analysis = optional(object({<br>      advanced_security = optional(object({<br>        status = string<br>      }))<br>      secret_scanning = optional(object({<br>        status = string<br>      }))<br>      secret_scanning_push_protection = optional(object({<br>        status = string<br>      }))<br>    }))<br>  }))</pre> | n/a | yes |
| <a name="input_security_config"></a> [security\_config](#input\_security\_config) | Configuration for security module including container, network, and compliance settings | <pre>object({<br>    enable_security_scanning = optional(bool, true)<br>    security_frameworks      = optional(list(string), [])<br>    container_security_config = optional(object({<br>      scanning_tools    = optional(list(string), [])<br>      runtime_security  = optional(list(string), [])<br>      registry_security = optional(list(string), [])<br>      uses_distroless   = optional(bool, false)<br>    }), {})<br>  })</pre> | `{}` | no |
| <a name="input_setup_dev_container"></a> [setup\_dev\_container](#input\_setup\_dev\_container) | Set up a development container for the project | `bool` | `false` | no |
| <a name="input_vs_code_workspace"></a> [vs\_code\_workspace](#input\_vs\_code\_workspace) | Configuration for VS Code workspace settings | <pre>object({<br>    settings = optional(map(any), {})<br>    extensions = optional(object({<br>      recommended = optional(list(string), [])<br>      required    = optional(list(string), [])<br>    }))<br>    tasks = optional(list(object({<br>      name    = string<br>      command = string<br>      group   = optional(string)<br>      options = optional(map(string))<br>    })), [])<br>    launch_configurations = optional(list(object({<br>      name          = string<br>      type          = string<br>      request       = string<br>      configuration = map(any)<br>    })), [])<br>  })</pre> | `null` | no |
| <a name="input_workspace_files"></a> [workspace\_files](#input\_workspace\_files) | Additional files to include in the VS Code workspace configuration | <pre>list(object({<br>    name = string<br>    path = string<br>  }))</pre> | `[]` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_all_repos"></a> [all\_repos](#output\_all\_repos) | Combined map of all repositories including master repo |
| <a name="output_base_repo"></a> [base\_repo](#output\_base\_repo) | All attributes of the master repository |
| <a name="output_base_repository"></a> [base\_repository](#output\_base\_repository) | All attributes of the base repository |
| <a name="output_base_repository_files"></a> [base\_repository\_files](#output\_base\_repository\_files) | Base repository files created in the workspace |
| <a name="output_copilot_configuration"></a> [copilot\_configuration](#output\_copilot\_configuration) | GitHub Copilot configuration and detected patterns |
| <a name="output_copilot_files"></a> [copilot\_files](#output\_copilot\_files) | Paths to the GitHub Copilot files for each repository |
| <a name="output_development_configuration"></a> [development\_configuration](#output\_development\_configuration) | Development standards and deployment configuration |
| <a name="output_infrastructure_configuration"></a> [infrastructure\_configuration](#output\_infrastructure\_configuration) | Infrastructure patterns and module configuration |
| <a name="output_project_repos"></a> [project\_repos](#output\_project\_repos) | Map of all project repositories and their attributes |
| <a name="output_quality_configuration"></a> [quality\_configuration](#output\_quality\_configuration) | Code quality standards and tooling configuration |
| <a name="output_repositories"></a> [repositories](#output\_repositories) | All project repositories |
| <a name="output_repository_names"></a> [repository\_names](#output\_repository\_names) | Map of repository names and their details |
| <a name="output_repository_urls"></a> [repository\_urls](#output\_repository\_urls) | Map of repository names and their URLs |
| <a name="output_security_configuration"></a> [security\_configuration](#output\_security\_configuration) | Complete security configuration derived from repository analysis |
| <a name="output_security_status"></a> [security\_status](#output\_security\_status) | Security configuration status for all repositories |
| <a name="output_workspace_file_path"></a> [workspace\_file\_path](#output\_workspace\_file\_path) | Path to the VS Code workspace file in the base repository |
<!-- END_TF_DOCS -->

## Project Status Update - Stabilization Phase

### Current Focus
The project is in a stabilization phase with the following priorities:

1. **Test Suite Stabilization**
   - Critical: All tests must work without GitHub Pro subscription
   - Required variables (project_prompt, repo_org, project_name) must be properly set in all test cases
   - Addressing end-to-end test teardown between test runs

2. **Preparation for Provider Transition**
   - All prompt and copilot instruction file generation will be moved to a new terraform provider
   - Freezing development of file generation features
   - Current file generation remains functional but will be deprecated

3. **Core Functionality**
   - Focusing on repository and workspace management stability
   - Ensuring proper handling of public visibility requirements
   - Validating core repository configuration features

### Immediate Action Items
1. Update test configurations to:
   - Remove GitHub Pro dependencies
   - Ensure consistent test variable setup
   - Fix repository teardown between tests

2. Document files marked for provider transition:
   - .github/copilot-instructions.md
   - .github/prompts/{repo-name}.prompt.md files
   - Any other prompt-related file generation

3. Stabilize existing functionality:
   - Repository creation and configuration
   - Development environment setup
   - Workspace configuration

### Development Guidelines
- No new features to be added during stabilization
- All repositories must be public (GitHub Pro limitation)
- Test cases must include required variables:
  - project_prompt
  - repo_org
  - project_name
- Run `terraform fmt` after any terraform file changes

For detailed information about specific features and configurations, please refer to the documentation in the `docs/` directory.

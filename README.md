# Terraform GitHub Project Module

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
| [github_branch_protection.project_repos](https://registry.terraform.io/providers/hashicorp/github/latest/docs/resources/branch_protection) | resource |
| [github_repository_file.base_files](https://registry.terraform.io/providers/hashicorp/github/latest/docs/resources/repository_file) | resource |
| [github_repository_file.base_repo_codeowners](https://registry.terraform.io/providers/hashicorp/github/latest/docs/resources/repository_file) | resource |
| [github_repository_file.base_repo_files](https://registry.terraform.io/providers/hashicorp/github/latest/docs/resources/repository_file) | resource |
| [github_repository_file.codespaces](https://registry.terraform.io/providers/hashicorp/github/latest/docs/resources/repository_file) | resource |
| [github_repository_file.devcontainer](https://registry.terraform.io/providers/hashicorp/github/latest/docs/resources/repository_file) | resource |
| [github_repository_file.docker_compose](https://registry.terraform.io/providers/hashicorp/github/latest/docs/resources/repository_file) | resource |
| [github_repository_file.workspace_config](https://registry.terraform.io/providers/hashicorp/github/latest/docs/resources/repository_file) | resource |
| [github_organization.org](https://registry.terraform.io/providers/hashicorp/github/latest/docs/data-sources/organization) | data source |
| [github_repository.existing_lookup](https://registry.terraform.io/providers/hashicorp/github/latest/docs/data-sources/repository) | data source |
| [github_repository.existing_repos](https://registry.terraform.io/providers/hashicorp/github/latest/docs/data-sources/repository) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_base_repository"></a> [base\_repository](#input\_base\_repository) | Configuration for the base repository. This repository serves as the foundation for the project and contains shared configurations. | <pre>object({<br>    # Core settings<br>    description     = optional(string)<br>    homepage_url    = optional(string)<br>    topics          = optional(list(string), ["project-base"])<br>    visibility      = optional(string, "private")<br>    has_issues      = optional(bool, true)<br>    has_wiki        = optional(bool, true)<br>    has_projects    = optional(bool, true)<br>    has_discussions = optional(bool, false)<br>    has_downloads   = optional(bool, false)<br><br>    # Git settings<br>    default_branch              = optional(string, "main")<br>    allow_merge_commit          = optional(bool, false)<br>    allow_squash_merge          = optional(bool, true)<br>    allow_rebase_merge          = optional(bool, false)<br>    allow_auto_merge            = optional(bool, false)<br>    delete_branch_on_merge      = optional(bool, true)<br>    allow_update_branch         = optional(bool, true)<br>    merge_commit_title          = optional(string, "MERGE_MESSAGE")<br>    merge_commit_message        = optional(string, "PR_TITLE")<br>    squash_merge_commit_title   = optional(string, "COMMIT_OR_PR_TITLE")<br>    squash_merge_commit_message = optional(string, "COMMIT_MESSAGES")<br><br>    # Security settings<br>    vulnerability_alerts = optional(bool, true)<br>    security_and_analysis = optional(object({<br>      advanced_security = optional(object({<br>        status = string<br>      }))<br>      secret_scanning = optional(object({<br>        status = string<br>      }))<br>      secret_scanning_push_protection = optional(object({<br>        status = string<br>      }))<br>    }))<br>    require_signed_commits = optional(bool, false)<br><br>    # Protection settings<br>    enable_branch_protection = optional(bool, false)<br>    enforce_prs              = optional(bool, false)<br>    branch_protection = optional(object({<br>      enforce_admins                  = optional(bool, true)<br>      required_linear_history         = optional(bool, true)<br>      allow_force_pushes              = optional(bool, false)<br>      allow_deletions                 = optional(bool, false)<br>      require_conversation_resolution = optional(bool, true)<br>      required_approving_review_count = optional(number, 1)<br>      dismiss_stale_reviews           = optional(bool, true)<br>      require_code_owner_reviews      = optional(bool, true)<br>      required_status_checks = optional(object({<br>        strict   = optional(bool, true)<br>        contexts = optional(list(string), [])<br>      }))<br>    }))<br>    pull_request_bypassers = optional(list(string), [])<br><br>    # File management<br>    gitignore_template = optional(string)<br>    license_template   = optional(string)<br>    codeowners         = optional(list(string), [])<br>    create_codeowners  = optional(bool, true)<br>    extra_files = optional(list(object({<br>      path    = string<br>      content = string<br>    })), [])<br>    managed_extra_files = optional(list(object({<br>      path    = string<br>      content = string<br>    })))<br>    allow_unsigned_files = optional(bool, false)<br>    commit_author        = optional(string, "Terraform")<br>    commit_email         = optional(string, "terraform@roknsound.com")<br><br>    # Access control<br>    admin_teams      = optional(list(string), [])<br>    push_teams       = optional(list(string), [])<br>    maintain_teams   = optional(list(string), [])<br>    pull_teams       = optional(list(string), [])<br>    triage_teams     = optional(list(string), [])<br>    collaborators    = optional(map(string), {})<br>    github_org_teams = optional(list(any))<br><br>    # Additional settings<br>    template = optional(object({<br>      owner      = string<br>      repository = string<br>    }))<br>    pages = optional(object({<br>      branch = string<br>      path   = optional(string, "/")<br>      cname  = optional(string)<br>    }))<br>    archived           = optional(bool, false)<br>    archive_on_destroy = optional(bool, true)<br>    create_repo        = optional(bool, true)<br>    prefix             = optional(string)<br>    force_name         = optional(bool, false)<br>    is_template        = optional(bool, false)<br>  })</pre> | `{}` | no |
| <a name="input_codespaces"></a> [codespaces](#input\_codespaces) | Configuration for GitHub Codespaces | <pre>object({<br>    machine_type        = optional(string, "medium")<br>    retention_days      = optional(number, 30)<br>    prebuild_enabled    = optional(bool, false)<br>    env_vars            = optional(map(string), {})<br>    secrets             = optional(list(string), [])<br>    dotfiles_repository = optional(string)<br>    custom_image        = optional(string)<br>  })</pre> | `null` | no |
| <a name="input_copilot_instructions"></a> [copilot\_instructions](#input\_copilot\_instructions) | Custom Copilot instructions. If not provided, generated instructions will be used. | `string` | `null` | no |
| <a name="input_default_branch"></a> [default\_branch](#input\_default\_branch) | The default branch name for all repositories | `string` | `"main"` | no |
| <a name="input_development_container"></a> [development\_container](#input\_development\_container) | Configuration for development containers across repositories | <pre>object({<br>    base_image           = string<br>    install_tools        = optional(list(string), [])<br>    vs_code_extensions   = optional(list(string), [])<br>    env_vars             = optional(map(string), {})<br>    ports                = optional(list(string), [])<br>    post_create_commands = optional(list(string), [])<br>    docker_compose = optional(object({<br>      enabled = bool<br>      services = map(object({<br>        image       = string<br>        ports       = list(string)<br>        environment = map(string)<br>      }))<br>    }))<br>  })</pre> | `null` | no |
| <a name="input_enforce_prs"></a> [enforce\_prs](#input\_enforce\_prs) | Whether to enforce pull request reviews across all repositories | `bool` | `true` | no |
| <a name="input_environments"></a> [environments](#input\_environments) | Configuration for GitHub environments in each repository | <pre>map(list(object({<br>    name = string<br>    reviewers = optional(object({<br>      teams = optional(list(string), [])<br>      users = optional(list(string), [])<br>    }), {})<br>    deployment_branch_policy = optional(object({<br>      protected_branches     = optional(bool, true)<br>      custom_branch_policies = optional(bool, false)<br>    }), {})<br>    secrets = optional(list(object({<br>      name  = string<br>      value = string<br>    })), [])<br>    vars = optional(list(object({<br>      name  = string<br>      value = string<br>    })), [])<br>  })))</pre> | `{}` | no |
| <a name="input_initialization_script"></a> [initialization\_script](#input\_initialization\_script) | Optional custom initialization script to be appended to the default git clone commands | <pre>object({<br>    name    = string<br>    content = string<br>  })</pre> | `null` | no |
| <a name="input_project_name"></a> [project\_name](#input\_project\_name) | Name of the project. Will be used as the base repository name. | `string` | n/a | yes |
| <a name="input_project_prompt"></a> [project\_prompt](#input\_project\_prompt) | Content for the project's prompt file | `string` | n/a | yes |
| <a name="input_repo_org"></a> [repo\_org](#input\_repo\_org) | GitHub organization name | `string` | n/a | yes |
| <a name="input_repositories"></a> [repositories](#input\_repositories) | List of project repositories to create/manage | <pre>list(object({<br>    name                                    = string<br>    repo_org                                = optional(string)<br>    create_repo                             = optional(bool, true)<br>    github_repo_description                 = optional(string)<br>    github_repo_topics                      = optional(list(string), [])<br>    github_push_restrictions                = optional(list(string), [])<br>    github_is_private                       = optional(bool, true)<br>    github_auto_init                        = optional(bool, true)<br>    github_allow_merge_commit               = optional(bool, false)<br>    github_allow_squash_merge               = optional(bool, true)<br>    github_allow_rebase_merge               = optional(bool, false)<br>    github_delete_branch_on_merge           = optional(bool, true)<br>    github_has_projects                     = optional(bool, true)<br>    github_has_issues                       = optional(bool, false)<br>    github_has_wiki                         = optional(bool, true)<br>    github_default_branch                   = optional(string, "main")<br>    github_required_approving_review_count  = optional(number, 1)<br>    github_require_code_owner_reviews       = optional(bool, true)<br>    github_dismiss_stale_reviews            = optional(bool, true)<br>    github_enforce_admins_branch_protection = optional(bool, true)<br>    additional_codeowners                   = optional(list(string), [])<br>    prefix                                  = optional(string)<br>    force_name                              = optional(bool, false)<br>    github_org_teams                        = optional(list(any))<br>    template_repo_org                       = optional(string)<br>    template_repo                           = optional(string)<br>    is_template                             = optional(bool, false)<br>    admin_teams                             = optional(list(string), [])<br>    required_status_checks = optional(object({<br>      contexts = list(string)<br>      strict   = optional(bool, false)<br>    }))<br>    archived = optional(bool, false)<br>    secrets = optional(list(object({<br>      name  = string<br>      value = string<br>    })), [])<br>    vars = optional(list(object({<br>      name  = string<br>      value = string<br>    })), [])<br>    extra_files = optional(list(object({<br>      path    = string<br>      content = string<br>    })), [])<br>    managed_extra_files = optional(list(object({<br>      path    = string<br>      content = string<br>    })))<br>    pull_request_bypassers = optional(list(string), [])<br>    create_codeowners      = optional(bool, true)<br>    enforce_prs            = optional(bool, true)<br>    collaborators          = optional(map(string), {})<br>    archive_on_destroy     = optional(bool, true)<br>    vulnerability_alerts   = optional(bool, false)<br>    gitignore_template     = optional(string)<br>    homepage_url           = optional(string)<br>    security_and_analysis = optional(object({<br>      advanced_security = optional(object({<br>        status = string<br>      }))<br>      secret_scanning = optional(object({<br>        status = string<br>      }))<br>      secret_scanning_push_protection = optional(object({<br>        status = string<br>      }))<br>    }))<br>    prompt = optional(string)<br>  }))</pre> | `[]` | no |
| <a name="input_vs_code_workspace"></a> [vs\_code\_workspace](#input\_vs\_code\_workspace) | Configuration for VS Code workspace settings | <pre>object({<br>    settings = optional(map(any), {})<br>    extensions = optional(object({<br>      recommended = optional(list(string), [])<br>      required    = optional(list(string), [])<br>    }))<br>    tasks = optional(list(object({<br>      name    = string<br>      command = string<br>      group   = optional(string)<br>      options = optional(map(string))<br>    })), [])<br>    launch_configurations = optional(list(object({<br>      name          = string<br>      type          = string<br>      request       = string<br>      configuration = map(any)<br>    })), [])<br>  })</pre> | `null` | no |
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
| <a name="output_repository_names"></a> [repository\_names](#output\_repository\_names) | List of all repository names in the project |
| <a name="output_repository_urls"></a> [repository\_urls](#output\_repository\_urls) | Map of repository names to their various URLs |
| <a name="output_security_status"></a> [security\_status](#output\_security\_status) | Security configuration status for all repositories |
| <a name="output_workspace_file_path"></a> [workspace\_file\_path](#output\_workspace\_file\_path) | Path to the VS Code workspace file in the base repository |
<!-- END_TF_DOCS -->

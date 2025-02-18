[![Terraform Validation](https://github.com/HappyPathway/terraform-github-project/actions/workflows/terraform.yaml/badge.svg)](https://github.com/HappyPathway/terraform-github-project/actions/workflows/terraform.yaml)


[![Terraform Doc](https://github.com/HappyPathway/terraform-github-project/actions/workflows/terraform-doc.yaml/badge.svg)](https://github.com/HappyPathway/terraform-github-project/actions/workflows/terraform-doc.yaml)

# Terraform GitHub Project Module

This module helps you manage multiple GitHub repositories as a single project. It creates a master repository and any number of project repositories, with built-in support for GitHub Copilot code generation.

## Features

- Creates a master repository and multiple project repositories
- Configures GitHub Copilot prompts for AI-assisted development
- Automatically generates VS Code workspace configuration
- Supports all GitHub repository settings

## GitHub Copilot Integration

This module sets up reusable prompt files that GitHub Copilot uses to understand your project context:

- Master repository gets a `project-setup.prompt.md` file that guides project-wide code generation
- Each project repository gets a `repo-setup.prompt.md` file for repository-specific context
- VS Code will automatically use these prompts when generating code with GitHub Copilot

## Usage

```hcl
module "my_project" {
  source = "path/to/terraform-github-project"

  project_name = "my-awesome-project"
  
  # Copilot prompt for the master repository
  project_prompt = <<-EOT
    This project manages a microservices architecture with separate services for:
    - User authentication
    - Product catalog
    - Order processing
    Generate code following clean architecture principles and use TypeScript.
  EOT

  repositories = [
    {
      name = "auth-service"
      prompt = <<-EOT
        This is the authentication service.
        - Use OAuth2 and JWT
        - Include rate limiting
        - Follow security best practices
      EOT
      github_repo_description = "Authentication microservice"
      github_repo_topics = ["auth", "microservice", "typescript"]
    },
    {
      name = "catalog-service"
      prompt = <<-EOT
        Product catalog service with:
        - MongoDB for storage
        - GraphQL API
        - Full-text search capability
      EOT
      github_repo_description = "Product catalog microservice"
      github_repo_topics = ["catalog", "microservice", "typescript"]
    }
  ]

  # Optional: Add more files to the workspace
  workspace_files = [
    {
      name = "docs"
      path = "../project-docs"
    }
  ]
}
```

## Inputs

| Name | Description | Type | Required |
|------|-------------|------|----------|
| project_name | Name of the project | string | yes |
| project_prompt | GitHub Copilot prompt for the master repository | string | yes |
| repositories | List of repository configurations | list(object) | yes |
| workspace_files | Additional files to include in workspace | list(object) | no |

Each repository in the `repositories` list supports all GitHub repository settings plus a `prompt` field for Copilot instructions.

## Outputs

| Name | Description |
|------|-------------|
| master_repo | Information about the created master repository |
| project_repos | Map of created project repositories and their details |
| workspace_file_path | Path to the generated VS Code workspace file |
| copilot_prompts | Paths to the GitHub Copilot prompt files |

## VS Code Integration

The module creates a `.code-workspace` file in your master repository that:
- Links all project repositories
- Enables easy navigation between repos
- Allows GitHub Copilot to access project-wide context

## Notes

- Prompts are used by GitHub Copilot for code generation, not as documentation
- Each repository's prompt should describe its specific purpose and requirements
- The master repository's prompt should provide project-wide context

<!-- BEGIN_TF_DOCS -->
{{ .Content }}
<!-- END_TF_DOCS -->
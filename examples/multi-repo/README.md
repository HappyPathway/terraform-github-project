# Multi-Repository Example

This example demonstrates managing multiple related repositories with standardized configuration and workspace setup.

## Features Demonstrated
- Base repository with project configuration
- Multiple related service repositories
- VS Code workspace configuration
- Repository relationships and organization
- All public repositories (no GitHub Pro required)

## Repository Structure
- Base repository: Project configuration and workspace setup
- service-api: Core REST API service
- service-worker: Background processing service
- frontend: Web application interface

## Usage

1. Create a terraform.tfvars file with your configuration:
```hcl
repo_org = "your-org-name"
project_name = "your-project-name"
project_prompt = "Multi-repository project demonstrating service relationships"
```

2. Initialize and apply:
```bash
terraform init
terraform apply
```

3. Clone repositories using the generated workspace script:
```bash
cd your-project-name
./projg
```

4. Open the generated VS Code workspace file to start development

## Requirements
- GitHub personal access token with repo permissions
- No GitHub Pro subscription required
- terraform 1.6.0 or later
- GitHub provider 5.0 or later
- Visual Studio Code for development
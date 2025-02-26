# Minimal Example

This example demonstrates the most basic usage of the terraform-github-project module to create a single public repository with required configuration.

## Features Demonstrated
- Basic repository creation
- Public visibility (no GitHub Pro required)
- Required variable configuration

## Usage

1. Create a terraform.tfvars file with your configuration:
```hcl
repo_org = "your-org-name"
project_name = "your-project-name"
project_prompt = "Description of your project for AI tooling"
```

2. Initialize and apply:
```bash
terraform init
terraform apply
```

## Requirements
- GitHub personal access token with repo permissions
- No GitHub Pro subscription required
- terraform 1.6.0 or later
- GitHub provider 5.0 or later
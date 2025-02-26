# Infrastructure Modules Example

This example demonstrates managing a collection of infrastructure modules following patterns from real-world configurations like gcp-kubernetes and morpheus-workspace.

## Features Demonstrated
- Infrastructure module organization
- Module documentation and testing
- Development tooling configuration
- Repository grouping by responsibility
- All public repositories (no GitHub Pro required)

## Repository Structure
- Base repository: Core configuration and workspace setup
- terraform-{cloud}-compute: Compute resource management
- terraform-{cloud}-networking: Network configuration
- terraform-{cloud}-storage: Storage resource management
- terraform-{cloud}-monitoring: Monitoring and logging setup

## Usage

1. Create a terraform.tfvars file with your configuration:
```hcl
repo_org = "your-org-name"
project_name = "your-infra-project"
project_prompt = "Infrastructure modules for cloud resource management"
cloud_provider = "aws"  # or gcp, azure
```

2. Initialize and apply:
```bash
terraform init
terraform apply
```

3. Clone repositories using the generated workspace script:
```bash
cd your-infra-project
./projg
```

4. Open the generated VS Code workspace file to start development

## Requirements
- GitHub personal access token with repo permissions
- No GitHub Pro subscription required
- terraform 1.6.0 or later
- GitHub provider 5.0 or later
- Visual Studio Code for development
- terraform-docs for documentation generation
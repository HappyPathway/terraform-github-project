# Python Service Example

This example demonstrates how to use the terraform-github-project module to set up a Python microservice project with full development environment configuration.

## Features Demonstrated

- DevContainer configuration with Python 3.11 base image
- Multi-container development setup with Redis and PostgreSQL
- VS Code workspace settings optimized for Python development
- GitHub Codespaces configuration with prebuilds enabled
- Poetry for dependency management
- FastAPI development configuration
- Automated test and formatting tasks

## Usage

1. Initialize Terraform:
```bash
terraform init
```

2. Review the planned changes:
```bash
terraform plan
```

3. Apply the configuration:
```bash
terraform apply
```

## Project Structure

This example creates:
- A base repository `python-service` for project-wide configuration
- Two service repositories:
  - `service-api`: Main API service
  - `service-worker`: Background worker service

Each repository will be configured with:
- Development container setup
- VS Code workspace settings
- GitHub Codespaces configuration
- Python-specific tooling and extensions

## Development Environment Features

### DevContainer Configuration
- Python 3.11 base image
- Poetry for dependency management
- Common development tools
- Integrated database services via Docker Compose
- Port forwarding for API and debugging

### VS Code Integration
- Python extension pack
- Black formatter
- GitHub Copilot
- Custom tasks for common operations
- Debug configurations for FastAPI
- Consistent code style settings

### GitHub Codespaces
- Medium compute resources
- 30-day retention policy
- Prebuilds enabled for faster startup
- Development-specific environment variables
- Secure secret management

## Adding More Services

To add more services to the project, extend the `repositories` list in the configuration:

```hcl
repositories = [
  {
    name        = "service-api"
    description = "Main API service"
  },
  {
    name        = "service-worker"
    description = "Background worker service"
  },
  {
    name        = "new-service"
    description = "Additional service"
  }
]
```

## Customizing the Development Environment

### Modifying DevContainer Settings
Update the `development_container` block to change:
- Base image version
- Installed tools
- VS Code extensions
- Environment variables
- Port configurations
- Docker Compose services

### Adjusting VS Code Settings
Modify the `vs_code_workspace` block to customize:
- Editor preferences
- Python settings
- Required extensions
- Custom tasks
- Debug configurations
# AWS Platform Infrastructure Example

This example demonstrates how to set up a Terraform workspace for managing AWS infrastructure with reusable modules.

## Project Structure

- **Base Repository**: Central infrastructure documentation and standards
- **Platform Core**: Core AWS infrastructure (VPC, networking, shared services)
- **Module EKS**: Reusable EKS cluster module
- **Module RDS**: Reusable RDS database module
- **Environments**: Environment-specific configurations

## Key Features

### Infrastructure Quality Checks
- terraform-fmt validation
- terraform-docs automation
- tflint for best practices
- checkov for security compliance
- infracost for cost estimation

### Module Repositories
- Standardized documentation using terraform-docs
- Consistent formatting enforcement
- Module-specific testing requirements
- Reusable module patterns

### Environment Management
- Separate development and production configurations
- Region-specific variables
- Protected production deployments
- Team-based approval processes

### Security Controls
- Required status checks for all changes
- Two-reviewer requirement for core changes
- Code owner review requirements
- Linear history enforcement

## Documentation
- Automated README generation
- Standardized module documentation
- GitHub Pages integration
- Centralized documentation site

## Usage

```hcl
module "terraform_workspace" {
  source = "../../"

  project_name    = "aws-platform"
  repo_org        = "my-org"
  project_prompt  = "AWS infrastructure modules and platform configuration"
  
  # See main.tf for full configuration
}
```

## Additional Configuration

The `.terraform-docs.yml` file is automatically added to all repositories, ensuring consistent documentation across modules.
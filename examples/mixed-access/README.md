# Mixed Access Project Example

This example demonstrates how to effectively manage a project with both public and private repositories using GitHub Free tier.

## Project Structure

```
my-saas-app/           # Main project repository (public)
├── public-sdk/        # Client SDK (public)
├── public-examples/   # Usage examples (public)
├── backend-services/  # Backend services (private)
└── deployment-config/ # Deployment configuration (private)
```

## Key Features

### Public Repositories
These repositories leverage all GitHub Free tier features:
- Branch protection rules
- Required code reviews
- Status check requirements
- Code owner reviews
- Automated dependency updates

### Private Repositories
These repositories use alternative workflows due to Free tier limitations:
- Conventional commit enforcement
- Manual review processes
- External CI/CD checks
- Clear contribution guidelines
- Security practice documentation

## Repository Overview

1. **Main Repository (Public)**
   - Project documentation
   - Architectural guidelines
   - Getting started guides
   - GitHub Pages enabled

2. **Public SDK (Public)**
   - Full GitHub Free features
   - Strict review requirements
   - Comprehensive CI checks
   - Automated publishing

3. **Examples (Public)**
   - Basic branch protection
   - Easy contribution process
   - Automated testing
   - Documentation checks

4. **Backend Services (Private)**
   - Alternative review process
   - External CI enforcement
   - Clear guidelines
   - Security practices

5. **Deployment Config (Private)**
   - Security-focused workflow
   - Access controls
   - Secret management
   - Audit requirements

## Development Environment

The project includes a complete development environment with:
- Node.js base image
- Redis service
- Common development tools
- VS Code configuration

## Usage

1. Update the backend configuration for your environment
2. Modify the `repo_org` value
3. Adjust repository settings as needed
4. Deploy:
   ```bash
   terraform init
   terraform plan
   terraform apply
   ```

## Security Considerations

- Public repositories contain no sensitive information
- Private repositories have clear security guidelines
- External security scanning integrated
- Access control documentation
- Secret management practices

## Best Practices Demonstrated

1. **Repository Organization**
   - Public SDK for maximum accessibility
   - Private services for security
   - Clear separation of concerns
   - Documented workflows

2. **Review Processes**
   - Automated for public repos
   - Documented for private repos
   - Clear guidelines
   - Security focus

3. **Documentation**
   - Public API documentation
   - Private workflow guides
   - Security practices
   - Contribution processes

4. **Development Setup**
   - Consistent environment
   - Required tools
   - Local services
   - IDE configuration
# Java Microservices Platform Example

This example shows how to set up a retail platform using Spring Boot microservices architecture.

## Project Structure

- **Base Repository**: Project-wide standards and shared configurations
- **Product Service**: Product catalog management
- **Order Service**: Order processing
- **API Gateway**: Spring Cloud Gateway for routing
- **Shared Library**: Common utilities and domain models

## Key Features

### Microservice Repositories
- Java-specific gitignore templates
- Strict branch protection
- SonarQube integration
- Maven build and integration test checks
- Shared library for common code
- Environment-specific Spring profiles

### Environment Configuration
- Development, Staging, and Production environments
- Team-based review requirements
- Protected deployment branches in production
- Environment-specific Spring profiles

### Security Features
- GitHub Advanced Security enabled
- Required code owner reviews
- Two-reviewer requirement for critical services
- Linear Git history enforced

## Usage

```hcl
module "java_microservices" {
  source = "../../"

  project_name    = "retail-platform"
  repo_org        = "my-org"
  project_prompt  = "Java Spring Boot microservices platform for retail operations"
  
  # See main.tf for full configuration
}
```
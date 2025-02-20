# Django E-commerce Project Example

This example demonstrates setting up a Django-based e-commerce project with separate repositories for backend API, frontend, and infrastructure.

## Project Structure

- **Base Repository**: Central documentation and project-wide configuration
- **Backend API**: Django REST API service
- **Frontend**: React TypeScript application
- **Infrastructure**: AWS infrastructure configuration

## Key Features

### Backend API Repository
- Python-specific gitignore
- CI checks for pytest, black, isort, and flake8
- Development and Production environments
- Environment-specific Django settings
- Wiki and Issues enabled

### Frontend Repository
- Node-specific gitignore
- CI checks for npm test and eslint
- React/TypeScript configuration

### Infrastructure Repository
- Terraform-specific gitignore
- Infrastructure validation checks
- AWS resource management

## Security Features
- Advanced security scanning enabled
- Secret scanning with push protection
- Branch protection with required reviews

## Documentation
- GitHub Pages enabled
- Documentation hosted at gh-pages/docs

## Usage

```hcl
module "django_project" {
  source = "../../"

  project_name    = "django-ecommerce"
  repo_org        = "my-org"
  project_prompt  = "This is a Django e-commerce application with backend API and frontend components"
  
  # See main.tf for full configuration
}
```
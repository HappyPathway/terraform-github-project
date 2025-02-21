# ACME Shop Project Setup

This is the master repository for the ACME Shop e-commerce platform. The project consists of three main components:
- Frontend (React.js SPA)
- Backend API (Node.js/Express)
- Database (PostgreSQL)

## Project Structure
```
acme-shop/              # Main project repository (you are here)
├── acme-shop-frontend/ # React.js frontend application
├── acme-shop-api/     # Node.js backend API
└── acme-shop-db/      # Database migrations and schemas
```

## Development Guidelines
1. All code changes must go through pull requests
2. Each component has its own repository with specific setup instructions
3. Use conventional commits for all commit messages
4. Keep documentation up to date
5. Follow the defined code style guides in each repository

# Multi-tier Web Application Example

This example demonstrates how to configure a multi-tier web application project with GitHub Free tier compatibility.

## Repository Structure

- **Frontend**: Public repository with full branch protection
- **API**: Public repository with full branch protection
- **Database**: Private repository (limited features with Free tier)

## Branch Protection Strategy

### Public Repositories (Frontend & API)
All branch protection features are available:
- Required reviews
- Status checks
- Linear history
- Code owner reviews

### Private Repository (Database)
Limited features in GitHub Free tier:
- Manual review process (documented in CONTRIBUTING.md)
- Conventional commit messages
- External CI/CD validation

## Quick Start
```hcl
module "web_app" {
  source = "../../"

  project_name = "web-app"
  repo_org     = "my-org"

  repositories = [
    {
      name = "frontend"
      description = "Web application frontend"
      visibility = "public"
      enable_branch_protection = true
    },
    {
      name = "api"
      description = "Backend API service"
      visibility = "public"
      enable_branch_protection = true
    },
    {
      name = "database"
      description = "Database schemas and migrations"
      visibility = "private"
      # Branch protection automatically disabled for Free tier
    }
  ]
}
```

## Best Practices
1. Keep frontend and API repositories public for full feature access
2. Use private repositories only when absolutely necessary
3. Document manual review processes for private repositories
4. Consider GitHub Pro upgrade if advanced features are needed for private repos
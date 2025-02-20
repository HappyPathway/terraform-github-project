# Quick Start Guide

This guide will help you get started with the Terraform GitHub Project module quickly.

## What This Module Does

- Creates or manages a main repository and multiple project repositories
- Sets up GitHub Copilot to help write code for your project
- Creates smart coding guidelines based on your project setup
- Creates and commits a VS Code workspace file that connects all your repositories
- Configures all your GitHub repository settings in one place
- Keeps repository names consistent by default

## Basic Usage

Here's a simple example:

```hcl
module "my_project" {
  source = "path/to/terraform-github-project"
  project_name = "my-awesome-project"
  
  # Tell GitHub Copilot about your project
  project_prompt = <<-EOT
    This project is a simple web app with:
    - A frontend that shows data
    - An API that handles requests
    - A database that stores information
  EOT

  # Optional: Provide custom coding rules
  copilot_instructions = <<-EOT
    When writing code for this project:
    1. Use TypeScript for all code
    2. Write tests for all features
    3. Follow our security guidelines
  EOT

  # Set up your repositories
  repositories = [
    {
      name = "frontend"
      prompt = <<-EOT
        This is the frontend website.
        - Uses React
        - Shows user data
        - Looks nice and works well
      EOT
      github_repo_description = "Frontend website"
      github_repo_topics = ["react", "frontend"]
      github_is_private = false
    },
    {
      name = "api"
      prompt = <<-EOT
        This is the API service.
        - Handles data requests
        - Connects to the database
        - Keeps data safe
      EOT
      github_repo_description = "API service"
      github_repo_topics = ["api", "backend"]
      github_is_private = false
    }
  ]

  # Add extra folders to your workspace
  workspace_files = [
    {
      name = "docs"
      path = "./docs"
    }
  ]
}
```

## Important Notes

- The module can create smart coding rules by looking at your project setup
- You can provide your own coding rules using `copilot_instructions`
- The prompts are for GitHub Copilot to write better code, not just for documentation
- Each repository's prompt should explain what that specific repository does
- The main repository's prompt should explain how everything works together
- Repository names stay exactly as you set them (no automatic changes)
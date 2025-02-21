# GitHub Copilot Integration

This module is designed to help you instantly scaffold entire GitHub project workspaces that are GitHub Copilot-ready.

## How GitHub Copilot Helps

The module creates special files that help GitHub Copilot understand your code:
- Your main repository gets a `project-setup.prompt.md` file that explains the whole project
- Each repository gets a `repo-setup.prompt.md` file that explains that specific part
- A `copilot-instructions.md` file is created with smart coding rules based on your setup
- VS Code uses these files automatically when GitHub Copilot helps write code

## Smart AI Guidelines

The module analyzes your project configuration to create intelligent coding guidelines. Here's what it looks at:

### 1. Project Structure
- Number of repositories and their roles
- Organization membership
- Repository visibility settings
- Repository descriptions and topics

### 2. Code Review Standards
- Pull request requirements
- Required reviewer count
- Code owner requirements
- Review staleness rules
- Administrator overrides

### 3. Git Workflow
- Allowed merge types (merge, squash, rebase)
- Branch cleanup settings
- Default branch names
- Branch protection rules

### 4. Security Setup
- Repository visibility
- Vulnerability scanning
- Secret management
- Code scanning configurations

### 5. Collaboration Features
- Project board settings
- Wiki availability
- Issue tracking
- Documentation requirements

## Custom Instructions

You can either:
- Let the module generate these guidelines automatically
- Provide your own with the `copilot_instructions` variable
- Or mix both by adding to the auto-generated guidelines

Example of auto-generated guidelines:
```hcl
module "my_project" {
  source = "path/to/terraform-github-project"
  project_name = "my-project"
  
  project_prompt = "This is a secure banking application"
  
  repositories = [
    {
      name = "frontend"
      github_is_private = true
      vulnerability_alerts = true
      security_and_analysis = {
        secret_scanning = {
          status = "enabled"
        }
      }
      # These settings will be detected and included in the guidelines
    }
  ]
}
```
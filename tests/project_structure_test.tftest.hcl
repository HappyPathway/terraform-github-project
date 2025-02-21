# Project Structure and Standardization Tests

run "validate_repository_structure" {
  command = plan

  variables {
    project_prompt = "Test project for project structure validation"
    repo_org = "test-org"
    project_name = "test-multi-repo"
    base_repository = {
      name = "test-multi-repo"
      description = "Test project structure validation"
      visibility = "public"
    }

    // Define standard repository structure
    repository_structure = {
      required_files = [
        "README.md",
        "CONTRIBUTING.md",
        ".github/CODEOWNERS",
        ".github/pull_request_template.md"
      ]
      required_directories = [
        "docs",
        "scripts",
        ".github/workflows"
      ]
    }

    repositories = [
      {
        name = "service-a"
        description = "Service A with standard structure"
      }
    ]
  }

  // Verify required files exist
  assert {
    condition = alltrue([
      for file in var.repository_structure.required_files :
      contains(keys(module.repository_files["service-a"].files), file)
    ])
    error_message = "Repository is missing required files"
  }

  // Verify required directories exist
  assert {
    condition = alltrue([
      for dir in var.repository_structure.required_directories :
      contains(keys(module.repository_files["service-a"].files), "${dir}/.gitkeep")
    ])
    error_message = "Repository is missing required directories"
  }
}

run "validate_documentation_standards" {
  command = plan

  variables {
    project_prompt = "Test project for project structure validation"
    repo_org = "test-org"
    project_name = "test-multi-repo"    
    base_repository = {
      name = "test-multi-repo"
      description = "Test documentation standards"
      visibility = "public"
    }

    documentation_requirements = {
      readme_sections = [
        "# Project Name",
        "## Overview",
        "## Prerequisites",
        "## Getting Started",
        "## Development",
        "## Deployment"
      ]
      contributing_sections = [
        "# Contributing Guide",
        "## Code Style",
        "## Pull Request Process"
      ]
    }

    repositories = [
      {
        name = "service-a"
        description = "Service A with standard docs"
      }
    ]
  }

  // Verify README.md contains required sections
  assert {
    condition = alltrue([
      for section in var.documentation_requirements.readme_sections :
      contains(module.repository_files["service-a"].files["README.md"].content, section)
    ])
    error_message = "README.md is missing required sections"
  }

  // Verify CONTRIBUTING.md contains required sections
  assert {
    condition = alltrue([
      for section in var.documentation_requirements.contributing_sections :
      contains(module.repository_files["service-a"].files["CONTRIBUTING.md"].content, section)
    ])
    error_message = "CONTRIBUTING.md is missing required sections"
  }
}

run "validate_monorepo_structure" {
  command = plan

  variables {
    base_repository = {
      name = "test-monorepo"
      description = "Test monorepo structure validation"
      visibility = "public"
    }

    monorepo_config = {
      workspace_type = "monorepo"
      package_structure = {
        apps = {
          path = "apps"
          required_files = ["package.json", "tsconfig.json"]
        }
        packages = {
          path = "packages"
          required_files = ["package.json", "tsconfig.json"]
        }
        infrastructure = {
          path = "infrastructure"
          required_files = ["main.tf", "variables.tf"]
        }
      }
    }
  }

  // Verify monorepo directory structure
  assert {
    condition = alltrue([
      for dir in keys(var.monorepo_config.package_structure) :
      contains(module.repository_files["test-monorepo"].directories, var.monorepo_config.package_structure[dir].path)
    ])
    error_message = "Monorepo is missing required top-level directories"
  }

  // Verify each package type has required files
  assert {
    condition = alltrue(flatten([
      for dir, config in var.monorepo_config.package_structure : [
        for file in config.required_files :
        contains(keys(module.repository_files["test-monorepo"].files), "${config.path}/_template/${file}")
      ]
    ]))
    error_message = "Package template directories are missing required files"
  }
}
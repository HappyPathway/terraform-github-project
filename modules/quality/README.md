# Quality Module

This module analyzes repository configurations to determine code quality requirements and tooling. It helps maintain consistent code quality standards across all repositories.

## Features

### Code Quality Standards
- Enforces linting requirements
- Manages type safety configuration
- Requires documentation standards
- Sets code formatting rules

### Quality Tooling
- Detects and configures linting tools
- Manages code formatting tools
- Sets up documentation generators
- Configures type checking tools

## Usage

```hcl
module "quality" {
  source = "./modules/quality"

  repositories = [
    {
      name = "typescript-service"
      github_repo_topics = ["typescript", "eslint", "prettier", "jest"]
      prompt = "TypeScript service with strict quality requirements"
    }
  ]

  quality_config = {
    linting_required = true
    type_safety = true
    documentation_required = true
    formatting_tools = ["prettier", "eslint"]
    linting_tools = ["eslint"]
    documentation_tools = ["typedoc"]
  }
}
```

## Variables

### Required Variables
- `repositories` - List of repository configurations to analyze

### Optional Variables
- `quality_config` - Code quality configuration including:
  - `linting_required` - Whether linting is required
  - `type_safety` - Whether type safety is enforced
  - `documentation_required` - Whether documentation is required
  - `formatting_tools` - List of code formatting tools
  - `linting_tools` - List of linting tools
  - `documentation_tools` - List of documentation tools

## Outputs

### Quality Configuration
- `code_quality_config` - Complete quality configuration
- `detected_linting_tools` - Linting tools detected
- `detected_formatting_tools` - Code formatting tools detected
- `detected_documentation_tools` - Documentation tools detected
- `has_type_checking` - Whether type checking is enabled
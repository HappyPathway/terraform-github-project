# GitHub Copilot Project Instructions

## Project Overview: ${project_name}

### Technology Stack
%{ if length(languages) > 0 ~}
Primary Languages:
${join("\n", [for lang in languages : "- ${lang}"])}
%{ endif ~}

%{ if length(frameworks) > 0 ~}
Frameworks:
${join("\n", [for framework in frameworks : "- ${framework}"])}
%{ endif ~}

### Development Standards

#### Code Quality
%{ if length(linting_tools) > 0 ~}
Linting Tools:
${join("\n", [for tool in linting_tools : "- ${tool}"])}
%{ endif ~}

%{ if length(testing_tools) > 0 ~}
Testing Tools:
${join("\n", [for tool in testing_tools : "- ${tool}"])}
%{ endif ~}

#### Pull Request Requirements
%{ if enforce_prs ~}
- Pull requests are required for all changes
- Code owners must review changes in their areas
%{ if !github_pro_enabled ~}
- Note: Branch protection requires public repositories or GitHub Pro
%{ endif ~}
%{ endif ~}

### Infrastructure
%{ if length(iac_tools) > 0 ~}
Infrastructure as Code:
${join("\n", [for tool in iac_tools : "- ${tool}"])}
%{ endif ~}

%{ if length(cloud_providers) > 0 ~}
Cloud Providers:
${join("\n", [for provider in cloud_providers : "- ${provider}"])}
%{ endif ~}

### Security
%{ if length(security_tools) > 0 ~}
Security Tools:
${join("\n", [for tool in security_tools : "- ${tool}"])}
%{ endif ~}

## Best Practices
1. Follow language-specific coding standards
2. Write clear commit messages
3. Keep documentation up to date
4. Write tests for new features
5. Follow security best practices

## Code Generation Guidelines
1. Follow existing patterns in the codebase
2. Include error handling
3. Add appropriate logging
4. Write clear comments
5. Include type hints/definitions where applicable

## Repository Structure
/.github/
  - Contains GitHub-specific configurations
  - Includes workflow definitions
  - Houses repository-specific documentation

/docs/
  - Technical documentation
  - API documentation
  - Architecture diagrams

/src/ or equivalent
  - Main source code
  - Follows language-specific conventions

/tests/
  - Test files
  - Test fixtures
  - Test utilities
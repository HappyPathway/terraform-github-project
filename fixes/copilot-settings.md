# Module Output Standardization Plan

## Objective
Standardize the file outputs from all modules to use a consistent format and ensure prompt files are properly placed in `.github/prompts` directory.

## Required Changes

### 1. Module Output Structure
Each module needs to output files in the format:
```hcl
output "files" {
  value = list(object({
    name    = string
    content = string
  }))
}
```

### 2. Module-Specific Changes

#### Security Module
- Add outputs for security policy files
- Move any prompt files to `.github/prompts/*.prompt.md`
- Expected files:
  - `.github/prompts/security-requirements.prompt.md`
  - `.github/security/SECURITY.md` (if exists)

#### Development Module
- Add outputs for development-related files
- Move any prompt files to `.github/prompts/*.prompt.md`
- Expected files:
  - `.github/prompts/development-guidelines.prompt.md`
  - `.github/workflows/*.yml` files

#### Infrastructure Module
- Add outputs for IaC-related files
- Move any prompt files to `.github/prompts/*.prompt.md`
- Expected files:
  - `.github/prompts/infrastructure-guidelines.prompt.md`
  - Any terraform-specific configuration files

#### Quality Module
- Add outputs for quality-related files
- Move any prompt files to `.github/prompts/*.prompt.md`
- Expected files:
  - `.github/prompts/quality-standards.prompt.md`
  - Quality check configuration files

#### Copilot Module
- Add outputs for copilot-related files
- Move any prompt files to `.github/prompts/*.prompt.md`
- Expected files:
  - `.github/prompts/copilot-instructions.prompt.md`
  - `.github/copilot/configuration.yml` (if needed)

### 3. Main.tf Updates
- Update the repository_files module call to include all module file outputs
- Add new local variable to combine all module file outputs:
```hcl
locals {
  module_files = concat(
    module.security.files,
    module.development.files,
    module.infrastructure.files,
    module.quality.files,
    module.copilot.files
  )
  all_repository_files = concat(
    local.standard_files,
    local.project_prompt_files,
    local.workspace_config_files,
    local.module_files
  )
}
```

## Implementation Order
1. Create output definitions in each module
2. Update each module's file generation to use the standardized format
3. Move any existing prompt files to `.github/prompts/`
4. Update main.tf to collect and pass all files to repository_files module
5. Test file generation and placement
6. Run terraform fmt on all changed files

## Testing Strategy
1. Verify each module correctly outputs its files list
2. Ensure no duplicate files are created
3. Validate all prompt files are in `.github/prompts/`
4. Confirm file content is generated correctly
5. Run terraform plan to verify changes
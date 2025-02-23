# File Outputs Standardization Project

## Context
We are standardizing module outputs across the project to ensure consistent handling of generated files, particularly prompt files that should be placed under `.github/prompts` with `.prompt.md` extensions.

## Issue Reference
Tracking in issue #1

## Requirements
- All module outputs should use the standardized format: `list(object({ name = string, content = string }))`
- Prompt files must be placed in `.github/prompts/` directory
- All prompt files must use the `.prompt.md` extension
- File paths should be normalized across all modules
- Changes should be made incrementally to maintain stability

## Implementation Plan
See `fixes/copilot-settings.md` for detailed implementation plan and module-specific changes.

## Notes for Copilot
- When suggesting changes, maintain the standardized file output format
- Pay attention to file path construction, especially for prompt files
- Ensure all module changes are accompanied by appropriate tests
- Watch for potential file naming conflicts across modules
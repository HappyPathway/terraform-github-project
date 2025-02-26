# Test Errors and Fix Plan

## Current Issues

1. Mock Configuration Issues
   - Error: Incorrect mock structure for github_repository_file
   - Location: tests/mocks/github.tfmock.hcl
   - Impact: Test assertions may fail due to incorrect mock responses

2. DevContainer Configuration Issues
   - Error: DevContainer files not being created when expected
   - Location: tests/development_environment.tftest.hcl
   - Impact: validate_repository_files test failing

3. Workspace File Issues
   - Error: Invalid access to extensions attribute in workspace file content
   - Location: tests/development_environment.tftest.hcl
   - Impact: validate_workspace_config test failing

4. Repository Prompt Issues
   - Error: Incorrect key type in repository_files module
   - Location: main.tf
   - Impact: Multiple test failures in end-to-end and github_project tests

## Fix Plan

### Phase 1: Mock Configuration Updates
1. Configure proper mock structure for github_repository_file:
   - Use single mock resource with defaults
   - Include all required fields in defaults block
   - Remove any invalid nested blocks

### Phase 2: DevContainer Configuration Fixes
1. Update development_environment.tf to ensure DevContainer files are created when enabled
2. Verify docker-compose configuration is properly handled
3. Add proper validation for feature flags

### Phase 3: Workspace Configuration Fixes
1. Fix workspace file content structure validation
2. Ensure proper JSON structure in workspace file content
3. Update test assertions to match actual file structure

### Phase 4: Repository Prompt Fixes
1. Fix key type issue in repository_files module
2. Update prompt path handling to use proper string keys
3. Add validation for prompt path format

### Phase 5: Test Verification
1. Run `terraform test` to verify all fixes:
   - development_environment_configuration
   - validate_repository_files
   - validate_workspace_config
   - development_features_disabled_by_default
   - workspace_file_always_created

### Implementation Notes
- All repositories must be set to public visibility since Github Pro is disabled
- Each test case should validate the visibility setting is "public"
- Mock configurations should return consistent data matching the expected resource structure
- Each test case is independent and does not rely on state from other tests
- The development_files module is correctly referenced as ./modules/repository_files in the codebase
- DevContainer and workspace file contents must be valid JSON
- Repository prompt paths must be properly formatted strings
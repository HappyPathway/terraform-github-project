# Making terraform-github-project Work with GitHub Free by Default

This document outlines the necessary changes to make the terraform-github-project module work seamlessly for users with GitHub Free accounts.

## Current Issue

GitHub Free accounts have limitations on private repositories:
- Branch protection rules are only available for public repositories
- Advanced security features are limited
- Private repository features require GitHub Pro or higher

## Required Changes

### 1. Repository Visibility Changes

#### Base Repository
- Update default visibility to "public" in base_repository settings
- Add clear documentation about visibility options
- Add variable to control default visibility with "public" as default
- Keep option to override per repository

#### Project Repositories
- Make all example repositories public by default
- Update repository schema to default visibility to "public"
- Add warning comments when private visibility is selected

### 2. Branch Protection Modifications

- Add visibility check before applying branch protection
- Implement conditional logic for branch protection rules:
  ```hcl
  dynamic "branch_protection" {
    for_each = var.visibility == "public" ? [1] : []
    ...
  }
  ```
- Add warning when attempting branch protection on private repos

### 3. Security Features Adjustments

- Make advanced security features opt-in
- Remove advanced security defaults from examples
- Add documentation about which security features are available in Free tier
- Add validation to prevent enabling pro-only features on private repos

### 4. Documentation Updates

- Update README.md with GitHub Free tier compatibility notes
- Add section about upgrading to Pro if private repository features are needed
- Document which features require GitHub Pro
- Add troubleshooting guide for common Free tier limitations

### 5. Example Updates

Need to update all examples:
- minimal
- django-app
- java-microservices
- multi-tier-webapp
- python-service
- terraform-workspace

Changes for each example:
1. Set default visibility to "public"
2. Remove pro-only security features
3. Add comments explaining GitHub Free compatibility
4. Update documentation with tier requirements

### 6. Testing

Add test cases to verify:
- Public repositories work with all features
- Private repositories gracefully handle feature limitations
- Appropriate warnings are shown for unsupported configurations
- Branch protection works correctly on public repositories
- Security features are properly conditional

### 7. Migration Guide

Create a migration guide for existing users:
1. How to audit current repository visibility
2. Steps to make repositories public
3. How to maintain private repositories with limited features
4. Options for upgrading to Pro if needed

## Implementation Approach

1. Phase 1: Core Changes
   - Update base visibility defaults
   - Implement conditional branch protection
   - Update examples

2. Phase 2: Documentation & Validation
   - Add validation checks
   - Update documentation
   - Add migration guide

3. Phase 3: Testing & Quality Assurance
   - Add new test cases
   - Verify all examples
   - Test upgrade paths

## Benefits

- Wider accessibility for open source projects
- Clear expectations for free tier users
- Smooth upgrade path when needed
- Better documentation of feature requirements

## Considerations

- Some users may need to make repositories public
- Need to clearly communicate security implications
- Should provide guidance on when to upgrade to Pro
- Must maintain backward compatibility

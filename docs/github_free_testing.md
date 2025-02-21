# GitHub Free Tier Testing Guide

This guide explains the test suite for GitHub Free tier compatibility features.

## Test Overview

The test suite (`github_free_tier.tftest.hcl`) verifies that repositories behave correctly under GitHub Free tier limitations.

## Test Cases

### 1. Public Repository Features
Tests that public repositories have access to all features:
- Branch protection enabled
- Required reviews working
- Status checks enforced
- Code owner reviews available

### 2. Private Repository Limitations
Verifies Free tier limitations on private repos:
- Branch protection automatically disabled
- Warning file added automatically
- Validation errors for invalid configurations

### 3. Default Repository Settings
Checks default repository visibility:
- Base repository defaults to public
- Project repositories default to public
- Correct template selection

### 4. Warning File Creation
Validates warning file handling:
- Added to private repositories
- Contains correct content
- Proper file location

## Running Tests

Run the test suite with:
```bash
terraform test -filter=github_free_tier.tftest.hcl
```

## Adding New Tests

When adding new GitHub Free tier related features:
1. Add test cases to verify behavior
2. Include both success and failure scenarios
3. Test validation error messages
4. Verify warning file contents

## Common Test Issues

### Invalid Configuration Test
The "verify_validation_error_on_invalid_config" test should fail with:
- Error about branch protection on private repos
- Validation error in expected format
- Clear explanation of the issue

### Branch Protection Test
The branch protection tests should verify:
- Enabled for public repos
- Disabled for private repos
- Correct error messages
- Proper configuration
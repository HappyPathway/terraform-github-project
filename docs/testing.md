# Path Handling Test Plan

## Test Cases

### URL Format Tests
```hcl
documentation_sources = [
  {
    # Test Case 1: SSH URL
    repo = "git@github.com:hashicorp/terraform.git"
    name = "docs/terraform-ssh"
    path = "docs"
  },
  {
    # Test Case 2: HTTPS URL
    repo = "https://github.com/golang/go"
    name = "docs/go-https"
    path = "doc"
  },
  {
    # Test Case 3: Simple org/repo format
    repo = "kubernetes/kubernetes"
    name = "docs/k8s-simple"
    path = "docs"
  }
]
```

### Organization Collision Tests
```hcl
documentation_sources = [
  {
    # Two repos with same name in different orgs
    repo = "org1/api"
    name = "docs/api-1"
    path = "docs"
  },
  {
    repo = "org2/api"
    name = "docs/api-2"
    path = "docs"
  }
]
```

### Path Structure Tests
```hcl
documentation_sources = [
  {
    # Test subfolder paths
    repo = "org/repo"
    name = "docs/deep"
    path = "deeply/nested/docs"
  }
]
```

## Validation Steps

1. **Configuration Generation**
   ```bash
   terraform plan
   ```
   - Verify .gproj configuration is correct
   - Check workspace path mappings
   - Validate script installation

2. **Repository Cloning**
   ```bash
   ./gproj
   ```
   - Verify directory structure
   - Check authentication fallback
   - Validate tag/branch handling

3. **VS Code Integration**
   - Open workspace file
   - Verify folder visibility
   - Check path resolution
   - Test file access

4. **Edge Cases**
   - Test SSH key removal (force HTTPS)
   - Try invalid repo URLs
   - Test path collisions
   - Verify tag switching

## Expected Results

For each test case, verify:

1. **Directory Structure**
   ```
   ~/.gproj/docs/
   ├── org1/
   │   └── api/
   ├── org2/
   │   └── api/
   ├── hashicorp/
   │   └── terraform/
   └── golang/
       └── go/
   ```

2. **VS Code Navigation**
   - All folders visible
   - Proper names displayed
   - Working file links
   - Correct source tracking

3. **Git Operations**
   - Clean clone/update
   - Proper remote URLs
   - Working authentication
   - Tag/branch accuracy

## Failure Scenarios

Document cases that should fail with clear errors:
- Invalid URLs
- Missing permissions
- Path conflicts
- Configuration errors
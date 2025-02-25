# Directory Structure and Documentation Sources

## Directory Organization

The project uses the following directory structure:
- `/scripts/gproj`: Contains executable scripts and runtime files
- `/templates/gproj`: Contains template files used by the scripts

To maintain consistency, all script-related files should be moved to `/scripts/gproj`, while template files should remain in `/templates/gproj`.

## Documentation Sources

The `documentation_sources` variable defaults to using the top-level directory. You only need to specify the `path` if you want to reference a specific subdirectory:

```hcl
# Using default top-level directory
documentation_sources = [
  {
    repo = "https://github.com/org/repo"
    name = "full-repo-docs"
    # path defaults to "." automatically
  }
]

# Specifying a subdirectory
documentation_sources = [
  {
    repo = "https://github.com/org/repo"
    name = "specific-docs"
    path = "docs/specific-section"  # Only when you need a specific directory
  }
]
```

### Best Practices
- Let path default to "." when you want the entire repository
- Only specify path when you need a specific subdirectory
- Keep template files in `/templates/gproj`
- Keep executable scripts in `/scripts/gproj`

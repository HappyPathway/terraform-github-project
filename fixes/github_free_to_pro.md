# Migrating from GitHub Free to GitHub Pro

This guide explains how to enable Pro features after upgrading from GitHub Free.

## Prerequisites
1. GitHub Pro subscription activated
2. Admin access to repositories

## Enabling Pro Features

### For Private Repositories
Update your Terraform configuration to enable branch protection:

```hcl
repositories = [
  {
    name = "private-repo"
    visibility = "private"
    enable_branch_protection = true  # Now supported with Pro
    branch_protection = {
      required_approving_review_count = 2
      dismiss_stale_reviews = true
      require_code_owner_reviews = true
    }
  }
]
```

### Base Repository
If your base repository is private, update its configuration:

```hcl
base_repository = {
  visibility = "private"
  enable_branch_protection = true
  branch_protection = {
    enforce_admins = true
    required_linear_history = true
    require_code_owner_reviews = true
  }
}
```

## Migration Steps

1. Upgrade to GitHub Pro
2. Update Terraform configurations as shown above
3. Run `terraform plan` to verify changes
4. Apply changes with `terraform apply`
5. Verify branch protection rules are active
6. Update team documentation with new workflow

## Verification Checklist

- [ ] Branch protection enabled on private repos
- [ ] Required reviews enforced
- [ ] Code owner reviews required
- [ ] Advanced security features available
- [ ] Team notified of new requirements

## Best Practices

1. Plan the upgrade timing with your team
2. Document new requirements in CONTRIBUTING.md
3. Update CI/CD pipelines if needed
4. Train team on new protection rules
5. Monitor compliance with new workflows
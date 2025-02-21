# GitHub Free Tier Best Practices Guide

This guide helps you make the most of GitHub Free tier features while working around its limitations.

## Repository Strategy

### Public Repositories (Recommended)
For maximum feature access in Free tier:
- Make repositories public when possible
- Enable full branch protection
- Use required status checks
- Enforce code owner reviews
- Enable vulnerability alerts

### Private Repositories (Limited)
When privacy is required:
1. Document manual review process in CONTRIBUTING.md
2. Use conventional commit messages
3. Implement external CI/CD checks
4. Create clear team guidelines

## Working Around Limitations

### Branch Protection Alternative
Since private repos can't use branch protection in Free tier:

1. **Repository Settings**
   - Use protected branch name prefixes
   - Document branch naming rules
   - Set up external merge checks

2. **Team Process**
   - Create clear review guidelines
   - Use pull request templates
   - Maintain a contributors guide

3. **CI/CD Enforcement**
   - Set up external CI checks
   - Block merges on failed checks
   - Automate style enforcement

### Code Review Process

For private repositories:
1. Create detailed PR templates
2. Use conventional commits
3. Maintain a changelog
4. Document review requirements
5. Set up automated linting

## Security Best Practices

### Public Repositories
- Enable vulnerability alerts
- Use dependabot
- Implement security policies
- Monitor dependencies
- Regular security reviews

### Private Repositories
- Use secret scanning
- Implement secure workflows
- Regular security audits
- Clear security guidelines

## Migration Path

When you need more features:

1. **Stay on Free Tier**
   - Make repos public
   - Use external tools
   - Document processes

2. **Upgrade to Pro**
   - Enable branch protection
   - Add required reviews
   - Configure code owners
   - Enable advanced security

## Best Practices by Repository Type

### Documentation Repos
- Keep public for visibility
- Enable GitHub Pages
- Use pull request previews
- Maintain style guides

### Code Repositories
- Consider public visibility
- Use comprehensive CI
- Maintain test coverage
- Document security practices

### Internal Tools
- Accept limited features
- Strong documentation
- Clear team processes
- External automation

## Example Configurations

### Public Repository
```hcl
{
  name = "public-api"
  visibility = "public"
  enable_branch_protection = true
  branch_protection = {
    required_approving_review_count = 1
    dismiss_stale_reviews = true
  }
}
```

### Private Repository
```hcl
{
  name = "internal-config"
  visibility = "private"
  # Branch protection disabled automatically
  extra_files = [{
    path = "CONTRIBUTING.md"
    content = "... review process documentation ..."
  }]
}
```

## Tools and Integrations

### Recommended Free Tools
1. External CI services
2. Automated linting
3. Conventional commits
4. PR templates
5. Issue templates

### Process Automation
1. GitHub Actions (free tier)
2. Automated testing
3. Documentation checks
4. Style enforcement
5. Security scanning

## Regular Maintenance

### Repository Hygiene
- Regular dependency updates
- Documentation reviews
- Security assessments
- Process evaluations

### Team Communication
- Clear guidelines
- Regular training
- Process documentation
- Feedback cycles
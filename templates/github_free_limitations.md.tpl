# GitHub Free Tier Limitations

This file was automatically generated to inform about GitHub Free tier limitations.

## Repository Status
%{ if repo_visibility == "private" ~}
⚠️ This is a private repository using GitHub Free tier. The following limitations apply:
- Branch protection rules are not available
- Some advanced security features are limited
- Code owner reviews cannot be enforced

To enable these features:
1. Make the repository public by setting `visibility = "public"`, or
2. Upgrade to GitHub Pro

## Available Workarounds
While using GitHub Free tier with private repositories:
- Use branch naming conventions and documented processes
- Implement manual code review processes
- Use external CI/CD tools for additional checks
- Document security practices in CONTRIBUTING.md

## Need Help?
Refer to the project documentation for:
- Making repositories public safely
- Security considerations for public repositories
- When to upgrade to GitHub Pro
%{ else ~}
✅ This is a public repository. All GitHub Free tier features are available:
- Branch protection rules
- Required reviews
- Code owner enforcement
- Basic security features
%{ endif ~}

For more information, visit: https://docs.github.com/en/free-pro-team@latest/github/getting-started-with-github/githubs-products
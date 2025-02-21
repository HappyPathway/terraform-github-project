# Open Source Project Example

This example demonstrates how to set up a GitHub project that follows open source best practices while working within GitHub Free tier limitations.

## Project Structure

```
awesome-library/        # Main project repository (public)
├── core-library/      # Core library implementation (public)
├── examples/          # Example code and tutorials (public)
└── internal-tools/    # Internal tooling (private)
```

## Features Demonstrated

### GitHub Free Tier Best Practices
- Public repositories by default for maximum feature access
- Branch protection and reviews enabled for public repos
- Private repository for sensitive internal tools
- Automatic Free tier limitation warnings
- GitHub Pages for documentation

### Repository Configuration
1. **Main Repository (Public)**
   - Documentation website via GitHub Pages
   - Project-wide guidelines and standards
   - Full branch protection enabled

2. **Core Library (Public)**
   - Complete feature access with Free tier
   - Required status checks for quality
   - Code review requirements
   - Public API documentation

3. **Examples (Public)**
   - Tutorial code and implementation guides
   - Protected branches for quality
   - Easy contribution process
   - Build verification

4. **Internal Tools (Private)**
   - Limited features due to Free tier
   - Alternative workflow documentation
   - Manual review process
   - Clear limitation warnings

## Usage

1. Copy this example to your workspace
2. Update the backend configuration
3. Modify the organization and project names
4. Adjust repository settings as needed
5. Run Terraform commands:
   ```bash
   terraform init
   terraform plan
   terraform apply
   ```

## Security Considerations

- Public repositories are visible to everyone
- Private repository protects sensitive tools
- Branch protection on public repositories
- Environment protection for npm publishing
# Security Module

This module analyzes repository configurations to determine security requirements and patterns across container security, network security, and compliance.

## Submodules

### Container Security
- Detects container scanning requirements
- Identifies runtime security patterns
- Analyzes registry security needs
- Configures container security tooling

### Network Security
- Detects zero-trust architecture requirements
- Identifies service mesh usage
- Configures network policies
- Determines network security tools

### Compliance
- Identifies required compliance frameworks
- Determines data protection requirements
- Configures audit logging
- Sets up security controls

## Usage

```hcl
module "security" {
  source = "./modules/security"

  repositories = [
    {
      name = "app-container"
      github_repo_topics = ["docker", "container-security", "trivy"]
      prompt = "Container application with security requirements"
    }
  ]

  container_security_config = {
    scanning_tools = ["trivy", "snyk"]
    runtime_security = ["falco"]
    registry_security = ["harbor"]
    uses_distroless = true
  }
}
```

## Variables

### Required Variables
- `repositories` - List of repository configurations to analyze for security patterns

### Optional Variables
- `enable_security_scanning` - Enable security scanning features (default: true)
- `security_frameworks` - List of security frameworks to implement
- `container_security_config` - Configuration for container security features

## Outputs

### Container Security
- `container_security_config` - Effective container security configuration
- `container_scanning_required` - Whether container scanning is required

### Network Security
- `network_security_config` - Network security configuration
- `zero_trust_enabled` - Whether zero trust architecture is enabled

### Compliance
- `compliance_config` - Compliance configuration
- `encryption_required` - Whether encryption is required
- `audit_logging_enabled` - Whether audit logging is enabled
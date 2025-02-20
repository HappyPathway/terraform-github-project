# Security Features

## Security Analysis Features

The module automatically detects and provides guidelines for:

### 1. Secret Management
- HashiCorp Vault integration
- Cloud KMS (AWS, Azure, GCP)
- Certificate management
- Key rotation policies

### 2. Compliance Frameworks
- SOC2, ISO27001, HIPAA, GDPR
- Audit requirements
- Security controls
- Documentation standards

### 3. Container Security
- Image scanning tools
- Runtime protection
- Registry security
- Base image standards

### 4. Network Security
- Zero Trust architecture
- Service mesh security
- Network policies
- Traffic monitoring

### 5. Security Scanning
- SAST/DAST tools
- Dependency scanning
- Compliance checking
- Vulnerability reporting

## Example Security Setup

```hcl
module "secure_platform" {
  source = "path/to/terraform-github-project"
  project_name = "secure-platform"
  
  project_prompt = "Security-focused platform with secret management"
  
  repositories = [
    {
      name = "vault-config"
      github_repo_topics = [
        "vault",
        "hashicorp-vault",
        "vault-agent",
        "opa"
      ]
      prompt = "HashiCorp Vault configuration and policies"
    },
    {
      name = "cloud-secrets"
      github_repo_topics = [
        "aws-kms",
        "azure-key-vault",
        "external-secrets",
        "sealed-secrets"
      ]
      prompt = "Cloud key management and secret handling"
    },
    {
      name = "security-scanning"
      github_repo_topics = [
        "snyk",
        "trivy",
        "security-scanning",
        "vulnerability-management"
      ]
      prompt = "Security scanning and vulnerability management"
    }
  ]
}
locals {
  generated_copilot_instructions = <<-EOT
    # Project-Wide Coding Instructions

    ## Project Context
    ${var.project_prompt}

    ## Repository Structure
    This is a ${length(var.repositories)}-tier application with the following components:
    ${join("\n", [for repo in var.repositories : "- ${repo.name}: ${repo.github_repo_description}"])}

    ## Repository-Specific Guidelines
    ${join("\n\n", [for repo in var.repositories : <<-REPO
      ### ${repo.name}
      ${repo.prompt}
      
      Technical Stack:
      ${join("\n", formatlist("- %s", repo.github_repo_topics))}
    REPO
    ])}

    ## Derived Coding Standards
    The following standards have been automatically derived from the project configuration:

    1. Project Structure:
       - Each repository has its specific responsibility
       - Changes must maintain separation of concerns
       - Repository organization: ${var.repo_org}
       ${local.repo_analysis.templating.uses_templates ? "- Uses repository templates from: ${join(", ", local.repo_analysis.templating.template_sources)}" : ""}
       ${local.repo_analysis.templating.is_template ? "- Contains template repositories for reuse" : ""}

    2. Code Review Process:
       ${local.repo_analysis.review_requirements.required ? <<-EOT
         ${local.repo_analysis.collaboration.pr_bypass_allowed ? "- Some users/teams can bypass PR requirements" : ""}
       EOT
       : "- Pull request reviews are optional"}

    3. Git Workflow:
       - Preferred merge strategies: ${join(", ", compact(local.repo_analysis.merge_strategies))}
       - Branch cleanup on merge is ${local.repo_analysis.branch_cleanup ? "enabled" : "disabled"}
       - Default branch: ${coalesce(try(var.repositories[0].github_default_branch, null), "main")}

    4. Security:
       - Repositories are ${local.repo_analysis.security.private_repos ? "private" : "public"} by default
       - Vulnerability alerts are ${local.repo_analysis.security.vuln_alerts ? "enabled" : "disabled"}
       - Secret scanning is ${local.repo_analysis.security.scanning ? "enabled" : "disabled"}
       ${local.repo_analysis.security.secrets_exist ? "- GitHub Actions secrets are configured" : ""}

    5. Project Features:
       - Project boards: ${local.repo_analysis.features.has_projects ? "enabled" : "disabled"}
       - Wiki pages: ${local.repo_analysis.features.has_wiki ? "enabled" : "disabled"}
       - Issue tracking: ${local.repo_analysis.features.has_issues ? "enabled" : "disabled"}

    6. Collaboration:
       ${length(local.repo_analysis.collaboration.team_access) > 0 ? "- Team access: ${join(", ", local.repo_analysis.collaboration.team_access)}" : ""}
       ${local.repo_analysis.collaboration.has_collaborators ? "- External collaborators are configured" : ""}
       - Documentation must be maintained
       - Changes must be reflected in documentation
       - AI prompts should be kept up to date

    ## Repository Best Practices
    When working in this project:
    1. Follow the established merge strategy (${join(", ", compact(local.repo_analysis.merge_strategies))})
    2. Ensure all required status checks pass before merging
    3. Keep documentation and AI prompts current
    4. Respect the code review process
    5. Follow security guidelines for your repository type

    ## Development Standards
    ${length(local.development_standards.languages) > 0 ? <<-EOT
    1. Programming Languages:
       - Primary languages: ${join(", ", local.development_standards.languages)}
       - Follow language-specific best practices and style guides
    EOT
    : ""}

    ${length(local.development_standards.frameworks) > 0 ? <<-EOT
    2. Frameworks:
       - Used frameworks: ${join(", ", local.development_standards.frameworks)}
       - Follow framework-specific conventions and documentation
    EOT
    : ""}

    3. Testing Requirements:
       ${local.development_standards.testing_required ? <<-EOT
       - Testing is mandatory
       - Tests must pass before merging
       - Follow testing best practices for each language/framework
       EOT
       : "- Testing requirements not specified"}

    4. CI/CD:
       - Using ${local.development_standards.ci_tool}
       ${local.repo_analysis.branch_protection.status_checks != null ? "- Status checks must pass: ${join(", ", local.repo_analysis.branch_protection.status_checks)}" : ""}

    ## Code Quality Standards
    
    1. Static Analysis:
       ${local.code_quality.linting_required ? <<-EOT
       - Code linting is mandatory
       - Use project-specific linting rules
       - Fix all linting issues before committing
       EOT
       : "- No specific linting requirements defined"}
       
    2. Code Formatting:
       ${length(local.code_quality.formatting_tools) > 0 ? <<-EOT
       - Use standard formatters: ${join(", ", local.code_quality.formatting_tools)}
       - Format code before committing
       - Follow team-wide formatting conventions
       EOT
       : "- Follow language-specific formatting conventions"}

    3. Type Safety:
       ${local.code_quality.type_safety ? <<-EOT
       - Strong typing is enforced
       - Type definitions must be complete and accurate
       - Avoid using 'any' or equivalent loose types
       EOT
       : "- Follow language-specific type safety practices"}

    4. Documentation:
       ${local.code_quality.documentation_required ? <<-EOT
       - Documentation is required
       - Keep documentation up-to-date with changes
       - Include examples in documentation
       - Document complex logic and important decisions
       EOT
       : "- Document important changes and features"}

    ## Infrastructure as Code Standards
    ${length(local.infrastructure_patterns.iac_tools) > 0 ? <<-EOT
    1. IaC Tools:
       - Primary tools: ${join(", ", local.infrastructure_patterns.iac_tools)}
       - Follow tool-specific best practices and style guides
       ${local.infrastructure_patterns.uses_modules ? "- Use modular design patterns" : ""}
    EOT
    : ""}

    ${length(local.infrastructure_patterns.cloud_providers) > 0 ? <<-EOT
    2. Cloud Providers:
       - Target platforms: ${join(", ", local.infrastructure_patterns.cloud_providers)}
       - Follow cloud-specific security best practices
       - Use provider-recommended patterns
    EOT
    : ""}

    ${local.infrastructure_patterns.has_terraform ? <<-EOT
    3. Terraform Standards:
       - Use consistent formatting (terraform fmt)
       - Document all variables and outputs
       - Use version constraints for providers
       - Keep state files secure
       - Use workspaces appropriately
       - Follow standard module structure
    EOT
    : ""}

    ${local.infrastructure_patterns.has_kubernetes ? <<-EOT
    4. Kubernetes Standards:
       - Follow Kubernetes best practices
       - Use namespaces appropriately
       - Implement resource limits
       - Configure health checks
       - Use appropriate security contexts
       - Version all manifests
    EOT
    : ""}

    ${local.infrastructure_patterns.deployment_environment ? <<-EOT
    5. Environment Management:
       - Maintain separate configurations per environment
       - Use environment-specific variables
       - Document deployment procedures
       - Include rollback procedures
       - Test infrastructure changes
    EOT
    : ""}

    6. Infrastructure Security:
       - Follow principle of least privilege
       - Encrypt sensitive data
       - Use secure communication
       - Implement proper access controls
       - Regular security audits
       - Document security procedures

    ## Data Protection and Compliance
    ${local.compliance_patterns.data_protection.encryption_required ? <<-EOT
    1. Data Encryption:
       - Use encryption for data at rest
       - Implement encryption in transit
       - Follow key management best practices
       - Document encryption procedures
    EOT
    : ""}

    ${length(local.compliance_patterns.compliance_frameworks) > 0 ? <<-EOT
    2. Compliance Requirements:
       - Framework(s): ${join(", ", local.compliance_patterns.compliance_frameworks)}
       - Follow framework-specific controls
       - Maintain compliance documentation
       - Regular compliance audits
    EOT
    : ""}

    ${local.compliance_patterns.data_protection.audit_logging ? <<-EOT
    3. Audit and Logging:
       - Implement comprehensive logging
       - Maintain audit trails
       - Secure log storage
       - Regular log reviews
    EOT
    : ""}

    ${local.compliance_patterns.data_protection.backup_configured ? <<-EOT
    4. Backup and Recovery:
       - Regular backup procedures
       - Test recovery processes
       - Document backup strategy
       - Verify backup integrity
    EOT
    : ""}

    ${local.compliance_patterns.monitoring_required ? <<-EOT
    5. Monitoring and Alerting:
       - Set up comprehensive monitoring
       - Define alert thresholds
       - Create response procedures
       - Regular monitoring review
    EOT
    : ""}

    ## Deployment and Release Management
    ${length(local.deployment_patterns.strategies) > 0 ? <<-EOT
    1. Deployment Strategies:
       - Using: ${join(", ", local.deployment_patterns.strategies)}
       - Document deployment procedures
       - Include rollback plans
       - Test deployment processes
    EOT
    : ""}

    ${length(local.deployment_patterns.ci_cd_tools) > 0 ? <<-EOT
    2. CI/CD Pipeline:
       - Tools: ${join(", ", local.deployment_patterns.ci_cd_tools)}
       - Maintain pipeline as code
       - Include automated tests
       - Define quality gates
    EOT
    : ""}

    ${local.deployment_patterns.uses_gitops ? <<-EOT
    3. GitOps Practices:
       - Use declarative configurations
       - Maintain desired state in Git
       - Automate reconciliation
       - Document drift detection
    EOT
    : ""}

    ${local.deployment_patterns.feature_flags ? <<-EOT
    4. Feature Management:
       - Use feature flags for releases
       - Document flag lifecycles
       - Clean up unused flags
       - Test flag combinations
    EOT
    : ""}

    5. Release Process:
       - Follow semantic versioning
       - Maintain changelogs
       - Document dependencies
       - Version control configurations

    ## Infrastructure Module Development
    ${local.module_patterns.is_module ? <<-EOT
    1. Module Structure:
       - Follow standard Terraform module layout
       - Use consistent file naming:
         * versions.tf - Version constraints
       - Include README.md with usage examples
       - Document all variables and outputs
       ${length(local.module_patterns.module_types) > 0 ? "- Module types: ${join(", ", local.module_patterns.module_types)}" : ""}

    2. Module Development:
       - Use consistent variable naming
       - Implement proper validation rules
       - Add default values where appropriate
       - Include type constraints
       - Handle optional variables properly
       ${length(local.module_patterns.testing_frameworks) > 0 ? "- Testing frameworks: ${join(", ", local.module_patterns.testing_frameworks)}" : ""}

    3. Module Documentation:
       ${length(local.module_patterns.documentation_tools) > 0 ? "- Documentation tools: ${join(", ", local.module_patterns.documentation_tools)}" : "- Use terraform-docs for documentation"}
       - Include detailed examples
       - Document all requirements
       - Provide usage instructions
       - Explain variable meanings
       - Include architecture diagrams

    4. Module Testing:
       - Include example configurations
       - Write automated tests
       - Test with multiple providers
       - Validate all variables
       - Check output values
       - Test error conditions

    5. Module Versioning:
       - Follow semantic versioning
       - Tag all releases
       - Maintain CHANGELOG.md
       - Document breaking changes
       - Include upgrade guides
    EOT
    : ""}

    ## Secrets Management and Security Tools
    ${length(local.security_tooling.secret_managers) > 0 ? <<-EOT
    1. Secret Management Solutions:
       - Primary tools: ${join(", ", local.security_tooling.secret_managers)}
       - Follow secret management best practices
       - Use appropriate authentication methods
       - Implement secret rotation
    EOT
    : ""}

    ${local.security_tooling.vault_integration ? <<-EOT
    2. HashiCorp Vault Integration:
       - Use Vault for secrets management
       - Implement proper authentication methods
       - Follow principle of least privilege
       - Enable audit logging
       - Rotate secrets regularly
       - Use dynamic secrets where possible
       - Implement proper backup procedures
    EOT
    : ""}

    ${local.security_tooling.cloud_key_management.aws ? <<-EOT
    3. AWS Key Management:
       - Use AWS KMS for encryption
       - Implement proper IAM roles
       - Enable CloudTrail logging
       - Use customer managed keys
       - Follow AWS security best practices
       - Enable automatic key rotation
    EOT
    : ""}

    ${local.security_tooling.cloud_key_management.azure ? <<-EOT
    4. Azure Key Vault:
       - Use managed identities
       - Enable soft-delete and purge protection
       - Configure access policies
       - Enable monitoring and diagnostics
       - Follow Azure security baselines
       - Use key rotation policies
    EOT
    : ""}

    ${local.security_tooling.cloud_key_management.gcp ? <<-EOT
    5. Google Cloud KMS:
       - Use service accounts appropriately
       - Enable audit logging
       - Implement key rotation
       - Follow GCP security best practices
       - Use CMEK where appropriate
    EOT
    : ""}

    ${length(local.security_tooling.security_tools) > 0 ? <<-EOT
    6. Additional Security Tools:
       - Configured tools: ${join(", ", local.security_tooling.security_tools)}
       - Follow tool-specific security practices
       - Maintain up-to-date configurations
       - Regular security scanning
       - Monitor security alerts
    EOT
    : ""}

    7. Security Best Practices:
       - Never store secrets in code
       - Use environment-specific configurations
       - Implement proper access controls
       - Regular security audits
       - Document security procedures
       - Monitor security alerts
       - Keep security tools updated

    ## Security Certifications and Compliance
    ${length(local.security_certification.frameworks) > 0 ? <<-EOT
    1. Compliance Frameworks:
       - Required certifications: ${join(", ", local.security_certification.frameworks)}
       - Implement required controls
       - Regular compliance audits
       - Maintain documentation
    EOT
    : ""}

    ${local.security_certification.requires_audit ? <<-EOT
    2. Audit Requirements:
       - Implement audit logging
       - Track system changes
       - Monitor access patterns
       - Regular audit reviews
       - Maintain audit trail
    EOT
    : ""}

    ${length(local.security_certification.security_controls) > 0 ? <<-EOT
    3. Security Controls:
       - Implemented controls: ${join(", ", local.security_certification.security_controls)}
       - Follow control specifications
       - Regular control testing
       - Document exceptions
    EOT
    : ""}

    ## Container Security Standards
    ${length(local.container_security.scanning_tools) > 0 ? <<-EOT
    1. Container Scanning:
       - Use tools: ${join(", ", local.container_security.scanning_tools)}
       - Scan base images
       - Check for vulnerabilities
       - Monitor dependencies
       - Regular rescanning
    EOT
    : ""}

    ${length(local.container_security.runtime_security) > 0 ? <<-EOT
    2. Runtime Protection:
       - Implement: ${join(", ", local.container_security.runtime_security)}
       - Monitor container behavior
       - Enforce security policies
       - Alert on violations
    EOT
    : ""}

    ${length(local.container_security.registry_security) > 0 ? <<-EOT
    3. Registry Security:
       - Use: ${join(", ", local.container_security.registry_security)}
       - Sign container images
       - Verify signatures
       - Enforce trusted sources
    EOT
    : ""}

    4. Container Best Practices:
       ${local.container_security.uses_distroless ? "- Use distroless base images" : "- Minimize base image size"}
       - Keep base images updated
       - Run as non-root
       - Use read-only root filesystem
       - Implement resource limits
       - Scan during CI/CD

    ## Security Scanning and Analysis
    ${length(local.security_scanning_tools.sast_tools) > 0 ? <<-EOT
    1. Static Application Security Testing:
       - Tools in use: ${join(", ", local.security_scanning_tools.sast_tools)}
       - Scan during code reviews
       - Fix high-severity issues
       - Track security metrics
       - Regular baseline updates
    EOT
    : ""}

    ${length(local.security_scanning_tools.dast_tools) > 0 ? <<-EOT
    2. Dynamic Application Security Testing:
       - Tools configured: ${join(", ", local.security_scanning_tools.dast_tools)}
       - Test in staging environment
       - Regular security assessments
       - Monitor for vulnerabilities
       - Document findings
    EOT
    : ""}

    ${length(local.security_scanning_tools.dependency_scanning) > 0 ? <<-EOT
    3. Dependency Management:
       - Using: ${join(", ", local.security_scanning_tools.dependency_scanning)}
       - Regular dependency updates
       - Vulnerability monitoring
       - License compliance
       - Update scheduling
    EOT
    : ""}

    ${length(local.security_scanning_tools.compliance_tools) > 0 ? <<-EOT
    4. Compliance Scanning:
       - Tools enabled: ${join(", ", local.security_scanning_tools.compliance_tools)}
       - Regular compliance checks
       - Policy enforcement
       - Remediation tracking
       - Compliance reporting
    EOT
    : ""}

    ${length(local.security_scanning_tools.reporting_tools) > 0 ? <<-EOT
    5. Security Reporting:
       - Platforms: ${join(", ", local.security_scanning_tools.reporting_tools)}
       - Track security metrics
       - Regular reporting
       - Trend analysis
       - Issue management
    EOT
    : ""}

    6. Security Review Process:
       - Regular security assessments
       - Vulnerability management
       - Risk assessment
       - Security documentation
       - Incident response
       - Continuous monitoring

    ## Network Security Standards
    ${length(local.network_security.network_tools) > 0 ? <<-EOT
    1. Network Infrastructure:
       - Tools in use: ${join(", ", local.network_security.network_tools)}
       - Implement network segmentation
       - Use secure communication
       - Monitor network traffic
       - Regular security audits
    EOT
    : ""}

    ${local.network_security.zero_trust ? <<-EOT
    2. Zero Trust Architecture:
       - Implement zero trust principles
       - Verify all connections
       - Use strong authentication
       - Limit access scope
       - Monitor all traffic
    EOT
    : ""}

    ${local.network_security.service_mesh ? <<-EOT
    3. Service Mesh Security:
       - Enforce mutual TLS
       - Implement access policies
       - Monitor service traffic
       - Secure service discovery
       - Regular mesh updates
    EOT
    : ""}

    ${length(local.network_security.network_policies) > 0 ? <<-EOT
    4. Network Policies:
       - Implemented: ${join(", ", local.network_security.network_policies)}
       - Define ingress/egress rules
       - Implement least privilege
       - Regular policy review
       - Monitor policy violations
    EOT
    : ""}

    5. Network Best Practices:
       - Secure all endpoints
       - Implement defense in depth
       - Regular vulnerability scanning
       - Monitor network health
       - Document network architecture
       - Update security groups

    ## Data Protection Standards
    ${length(local.data_protection.encryption_tools) > 0 ? <<-EOT
    1. Data Encryption:
       - Tools in use: ${join(", ", local.data_protection.encryption_tools)}
       - Implement encryption at rest
       - Use strong encryption algorithms
       - Secure key management
       - Regular key rotation
    EOT
    : ""}

    ${length(local.data_protection.backup_tools) > 0 ? <<-EOT
    2. Backup Solutions:
       - Using: ${join(", ", local.data_protection.backup_tools)}
       - Regular backup schedule
       - Verify backup integrity
       - Test restoration process
       - Secure backup storage
    EOT
    : ""}

    ${length(local.data_protection.data_lifecycle) > 0 ? <<-EOT
    3. Data Lifecycle Management:
       - Implement: ${join(", ", local.data_protection.data_lifecycle)}
       - Define retention policies
       - Secure data deletion
       - Manage data classification
       - Document lifecycle rules
    EOT
    : ""}

    4. Data Protection Best Practices:
       - Classify sensitive data
       - Implement access controls
       - Monitor data access
       - Regular security reviews
       - Document procedures
       - Train team members

  EOT
}
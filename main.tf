locals {
  workspace_folders = concat(
    [{
      name = var.project_name
      path = "."
    }],
    [for repo in var.repositories : {
      name = repo.name
      path = "../${repo.name}"
    }],
    coalesce(var.workspace_files, [])
  )

  # Base security analysis
  security_scanning = anytrue([
    for repo in var.repositories : 
    try(repo.security_and_analysis.secret_scanning.status == "enabled" ||
        repo.security_and_analysis.secret_scanning_push_protection.status == "enabled", false)
  ])

  security_frameworks = distinct(flatten([
    for repo in var.repositories : [
      for topic in coalesce(repo.github_repo_topics, []) :
      upper(topic) if contains([
        "soc2", "iso27001", "fedramp", "pci-dss", 
        "hipaa", "gdpr", "ccpa", "nist"
      ], lower(topic))
    ]
  ]))

  # Enhanced repository analysis
  repo_analysis = {
    merge_strategies = distinct(flatten([
      for repo in var.repositories : [
        repo.github_allow_merge_commit == true ? "merge commits" : "",
        repo.github_allow_squash_merge == true ? "squash merging" : "",
        repo.github_allow_rebase_merge == true ? "rebase merging" : ""
      ]
    ]))
    branch_cleanup       = alltrue([for repo in var.repositories : coalesce(repo.github_delete_branch_on_merge, true)])
    review_requirements = {
      required         = var.enforce_prs
      min_reviewers   = min([for repo in var.repositories : coalesce(repo.github_required_approving_review_count, 1)]...)
      codeowners      = alltrue([for repo in var.repositories : coalesce(repo.github_require_code_owner_reviews, true)])
      dismiss_stale   = alltrue([for repo in var.repositories : coalesce(repo.github_dismiss_stale_reviews, true)])
      enforce_admins  = alltrue([for repo in var.repositories : coalesce(repo.github_enforce_admins_branch_protection, true)])
    }
    security = {
      private_repos   = alltrue([for repo in var.repositories : coalesce(repo.github_is_private, true)])
      vuln_alerts    = anytrue([for repo in var.repositories : coalesce(repo.vulnerability_alerts, false)])
      secrets_exist  = length(flatten([for repo in var.repositories : coalesce(repo.secrets, [])])) > 0
      scanning       = local.security_scanning
    }
    features = {
      has_projects = alltrue([for repo in var.repositories : coalesce(repo.github_has_projects, true)])
      has_wiki     = alltrue([for repo in var.repositories : coalesce(repo.github_has_wiki, true)])
      has_issues   = alltrue([for repo in var.repositories : coalesce(repo.github_has_issues, false)])
    }
    branch_protection = {
      status_checks = distinct(flatten([
        for repo in var.repositories : 
        try(repo.required_status_checks.contexts, [])
      ]))
      strict_updates = anytrue([
        for repo in var.repositories :
        try(repo.required_status_checks.strict, false)
      ])
    }
    
    templating = {
      uses_templates = anytrue([
        for repo in var.repositories :
        repo.template_repo != null
      ])
      is_template = anytrue([
        for repo in var.repositories :
        repo.is_template == true
      ])
      template_sources = distinct(compact([
        for repo in var.repositories :
        try(repo.template_repo_org, null)
      ]))
    }

    collaboration = {
      has_collaborators = anytrue([
        for repo in var.repositories :
        length(coalesce(repo.collaborators, {})) > 0
      ])
      pr_bypass_allowed = anytrue([
        for repo in var.repositories :
        length(coalesce(repo.pull_request_bypassers, [])) > 0
      ])
      team_access = distinct(flatten([
        for repo in var.repositories :
        coalesce(repo.github_org_teams, [])
      ]))
    }

    development_standards = {
      languages = distinct(flatten([
        for repo in var.repositories : [
          for topic in coalesce(repo.github_repo_topics, []) :
          lower(topic) if contains(["typescript", "javascript", "python", "go", "java", "ruby", "php"], lower(topic))
        ]
      ]))
      frameworks = distinct(flatten([
        for repo in var.repositories : [
          for topic in coalesce(repo.github_repo_topics, []) :
          lower(topic) if contains(["react", "vue", "angular", "express", "django", "flask", "spring"], lower(topic))
        ]
      ]))
      testing_required = anytrue([
        for repo in var.repositories :
        contains(coalesce(try(repo.required_status_checks.contexts, []), []), "test") ||
        contains(coalesce(repo.github_repo_topics, []), "testing")
      ])
      ci_tool = coalesce(
        contains(flatten([for repo in var.repositories : try(repo.required_status_checks.contexts, [])]), "github-actions") ? "GitHub Actions" :
        contains(flatten([for repo in var.repositories : try(repo.required_status_checks.contexts, [])]), "jenkins") ? "Jenkins" :
        contains(flatten([for repo in var.repositories : try(repo.required_status_checks.contexts, [])]), "travis") ? "Travis CI" :
        "Not specified"
      )
    }

    code_quality = {
      linting_required = anytrue([
        for repo in var.repositories :
        contains(coalesce(try(repo.required_status_checks.contexts, []), []), "lint") ||
        contains(coalesce(repo.github_repo_topics, []), "eslint") ||
        contains(coalesce(repo.github_repo_topics, []), "prettier")
      ])
      formatting_tools = distinct(flatten([
        for repo in var.repositories : [
          for topic in coalesce(repo.github_repo_topics, []) :
          lower(topic) if contains(["prettier", "black", "gofmt", "rustfmt"], lower(topic))
        ]
      ]))
      type_safety = anytrue([
        for repo in var.repositories :
        contains(coalesce(repo.github_repo_topics, []), "typescript") ||
        contains(coalesce(repo.github_repo_topics, []), "flow") ||
        contains(coalesce(repo.github_repo_topics, []), "mypy")
      ])
      documentation_required = anytrue([
        for repo in var.repositories :
        repo.github_has_wiki == true ||
        contains(coalesce(repo.github_repo_topics, []), "documentation")
      ])
    }

    infrastructure_patterns = {
      iac_tools = distinct(flatten([
        for repo in var.repositories : [
          for topic in coalesce(repo.github_repo_topics, []) :
          lower(topic) if contains(["terraform", "cloudformation", "ansible", "puppet", "kubernetes", "helm"], lower(topic))
        ]
      ]))
      cloud_providers = distinct(flatten([
        for repo in var.repositories : [
          for topic in coalesce(repo.github_repo_topics, []) :
          lower(topic) if contains(["aws", "azure", "gcp", "digitalocean", "oracle-cloud"], lower(topic))
        ]
      ]))
      has_terraform = anytrue([
        for repo in var.repositories :
        contains(coalesce(repo.github_repo_topics, []), "terraform") ||
        contains(coalesce(try(repo.required_status_checks.contexts, []), []), "terraform")
      ])
      has_kubernetes = anytrue([
        for repo in var.repositories :
        contains(coalesce(repo.github_repo_topics, []), "kubernetes") ||
        contains(coalesce(repo.github_repo_topics, []), "helm")
      ])
      uses_modules = anytrue([
        for repo in var.repositories :
        contains(coalesce(repo.github_repo_topics, []), "terraform-module")
      ])
      deployment_environment = anytrue([
        for repo in var.repositories :
        contains(coalesce(repo.github_repo_topics, []), "production") ||
        contains(coalesce(repo.github_repo_topics, []), "staging") ||
        contains(coalesce(repo.github_repo_topics, []), "development")
      ])
    }

    compliance_patterns = {
      data_protection = {
        encryption_required = anytrue([
          for repo in var.repositories :
          contains(coalesce(repo.github_repo_topics, []), "encryption") ||
          contains(coalesce(repo.github_repo_topics, []), "kms") ||
          local.security_scanning
        ])
        backup_configured = anytrue([
          for repo in var.repositories :
          contains(coalesce(repo.github_repo_topics, []), "backup") ||
          contains(coalesce(repo.github_repo_topics, []), "disaster-recovery")
        ])
        audit_logging = anytrue([
          for repo in var.repositories :
          contains(coalesce(repo.github_repo_topics, []), "audit") ||
          contains(coalesce(repo.github_repo_topics, []), "logging")
        ])
      }
      compliance_frameworks = local.security_frameworks
      requires_audit = anytrue([
        for repo in var.repositories :
        contains(coalesce(repo.github_repo_topics, []), "compliance") ||
        contains(coalesce(repo.github_repo_topics, []), "audit") ||
        length(local.security_frameworks) > 0
      ])
      monitoring_required = anytrue([
        for repo in var.repositories :
        contains(coalesce(repo.github_repo_topics, []), "monitoring") ||
        contains(coalesce(repo.github_repo_topics, []), "observability")
      ])
    }

    deployment_patterns = {
      strategies = distinct(flatten([
        for repo in var.repositories : [
          for topic in coalesce(repo.github_repo_topics, []) :
          lower(topic) if contains(["blue-green", "canary", "rolling-update", "gitops"], lower(topic))
        ]
      ]))
      ci_cd_tools = distinct(flatten([
        for repo in var.repositories : [
          for topic in coalesce(repo.github_repo_topics, []) :
          lower(topic) if contains(["github-actions", "jenkins", "gitlab-ci", "argocd", "flux"], lower(topic))
        ]
      ]))
      uses_gitops = anytrue([
        for repo in var.repositories :
        contains(coalesce(repo.github_repo_topics, []), "gitops") ||
        contains(coalesce(repo.github_repo_topics, []), "flux") ||
        contains(coalesce(repo.github_repo_topics, []), "argocd")
      ])
      feature_flags = anytrue([
        for repo in var.repositories :
        contains(coalesce(repo.github_repo_topics, []), "feature-flags") ||
        contains(coalesce(repo.github_repo_topics, []), "feature-toggles")
      ])
    }

    module_patterns = {
      is_module = anytrue([
        for repo in var.repositories :
        contains(coalesce(repo.github_repo_topics, []), "terraform-module") ||
        contains(coalesce(repo.github_repo_topics, []), "terraform-modules")
      ])
      module_types = distinct(flatten([
        for repo in var.repositories : [
          for topic in coalesce(repo.github_repo_topics, []) :
          lower(topic) if contains([
            "infrastructure-module", 
            "application-module", 
            "platform-module", 
            "composite-module"
          ], lower(topic))
        ]
      ]))
      testing_frameworks = distinct(flatten([
        for repo in var.repositories : [
          for topic in coalesce(repo.github_repo_topics, []) :
          lower(topic) if contains([
            "terratest", 
            "kitchen-terraform", 
            "terraform-compliance",
            "checkov"
          ], lower(topic))
        ]
      ]))
      documentation_tools = distinct(flatten([
        for repo in var.repositories : [
          for topic in coalesce(repo.github_repo_topics, []) :
          lower(topic) if contains([
            "terraform-docs",
            "mkdocs",
            "docusaurus"
          ], lower(topic))
        ]
      ]))
    }

    security_tooling = {
      secret_managers = distinct(flatten([
        for repo in var.repositories : [
          for topic in coalesce(repo.github_repo_topics, []) :
          lower(topic) if contains([
            "vault", "hashicorp-vault",
            "aws-kms", "azure-key-vault",
            "google-cloud-kms", "gsm",
            "sops", "mozilla-sops"
          ], lower(topic))
        ]
      ]))
      vault_integration = anytrue([
        for repo in var.repositories :
        contains(coalesce(repo.github_repo_topics, []), "vault") ||
        contains(coalesce(repo.github_repo_topics, []), "hashicorp-vault")
      ])
      cloud_key_management = {
        aws = anytrue([
          for repo in var.repositories :
          contains(coalesce(repo.github_repo_topics, []), "aws-kms") ||
          contains(coalesce(repo.github_repo_topics, []), "aws-secrets-manager")
        ])
        azure = anytrue([
          for repo in var.repositories :
          contains(coalesce(repo.github_repo_topics, []), "azure-key-vault") ||
          contains(coalesce(repo.github_repo_topics, []), "azure-managed-identity")
        ])
        gcp = anytrue([
          for repo in var.repositories :
          contains(coalesce(repo.github_repo_topics, []), "google-cloud-kms") ||
          contains(coalesce(repo.github_repo_topics, []), "google-secret-manager")
        ])
      }
      security_tools = distinct(flatten([
        for repo in var.repositories : [
          for topic in coalesce(repo.github_repo_topics, []) :
          lower(topic) if contains([
            "vault-agent", "vault-k8s",
            "cert-manager", "lets-encrypt",
            "sealed-secrets", "external-secrets",
            "opa", "gatekeeper",
            "snyk", "trivy"
          ], lower(topic))
        ]
      ]))
    }

    security_certification = {
      frameworks = local.security_frameworks
      requires_audit = anytrue([
        for repo in var.repositories :
        contains(coalesce(repo.github_repo_topics, []), "compliance") ||
        contains(coalesce(repo.github_repo_topics, []), "audit") ||
        length(local.security_frameworks) > 0
      ])
      security_controls = distinct(flatten([
        for repo in var.repositories : [
          for topic in coalesce(repo.github_repo_topics, []) :
          lower(topic) if contains([
            "rbac", "iam", "mfa", "zero-trust",
            "encryption-at-rest", "encryption-in-transit",
            "waf", "ddos-protection", "ids", "ips"
          ], lower(topic))
        ]
      ]))
    }

    container_security = {
      scanning_tools = distinct(flatten([
        for repo in var.repositories : [
          for topic in coalesce(repo.github_repo_topics, []) :
          lower(topic) if contains([
            "trivy", "clair", "aqua", "snyk-container",
            "docker-scan", "anchore", "grype"
          ], lower(topic))
        ]
      ]))
      runtime_security = distinct(flatten([
        for repo in var.repositories : [
          for topic in coalesce(repo.github_repo_topics, []) :
          lower(topic) if contains([
            "falco", "apparmor", "seccomp", "gatekeeper",
            "kyverno", "runtime-security"
          ], lower(topic))
        ]
      ]))
      registry_security = distinct(flatten([
        for repo in var.repositories : [
          for topic in coalesce(repo.github_repo_topics, []) :
          lower(topic) if contains([
            "harbor", "docker-trusted-registry", "cosign",
            "container-signing", "notary"
          ], lower(topic))
        ]
      ]))
      uses_distroless = anytrue([
        for repo in var.repositories :
        contains(coalesce(repo.github_repo_topics, []), "distroless")
      ])
    }

    security_scanning = {
      sast_tools = distinct(flatten([
        for repo in var.repositories : [
          for topic in coalesce(repo.github_repo_topics, []) :
          lower(topic) if contains([
            "sonarqube", "checkmarx", "fortify", 
            "coverity", "semgrep", "codacy",
            "snyk-code", "github-code-scanning"
          ], lower(topic))
        ]
      ]))
      dast_tools = distinct(flatten([
        for repo in var.repositories : [
          for topic in coalesce(repo.github_repo_topics, []) :
          lower(topic) if contains([
            "zap", "burp", "acunetix",
            "netsparker", "qualys"
          ], lower(topic))
        ]
      ]))
      dependency_scanning = distinct(flatten([
        for repo in var.repositories : [
          for topic in coalesce(repo.github_repo_topics, []) :
          lower(topic) if contains([
            "dependabot", "snyk-deps", "whitesource",
            "black-duck", "fossa", "renovate"
          ], lower(topic))
        ]
      ]))
      compliance_tools = distinct(flatten([
        for repo in var.repositories : [
          for topic in coalesce(repo.github_repo_topics, []) :
          lower(topic) if contains([
            "checkov", "terrascan", "tfsec",
            "cloudsploit", "prowler", "scout-suite",
            "security-hub", "qualys-compliance"
          ], lower(topic))
        ]
      ]))
      reporting_tools = distinct(flatten([
        for repo in var.repositories : [
          for topic in coalesce(repo.github_repo_topics, []) :
          lower(topic) if contains([
            "defectdojo", "security-hub", "jira-sec",
            "security-scorecard", "securityhub"
          ], lower(topic))
        ]
      ]))
    }

    network_security = {
      network_tools = distinct(flatten([
        for repo in var.repositories : [
          for topic in coalesce(repo.github_repo_topics, []) :
          lower(topic) if contains([
            "istio", "linkerd", "cilium", "calico",
            "consul", "envoy", "nginx", "traefik"
          ], lower(topic))
        ]
      ]))
      zero_trust = anytrue([
        for repo in var.repositories :
        contains(coalesce(repo.github_repo_topics, []), "zero-trust") ||
        contains(coalesce(repo.github_repo_topics, []), "beyondcorp")
      ])
      service_mesh = anytrue([
        for repo in var.repositories :
        contains(coalesce(repo.github_repo_topics, []), "istio") ||
        contains(coalesce(repo.github_repo_topics, []), "linkerd") ||
        contains(coalesce(repo.github_repo_topics, []), "consul")
      ])
      network_policies = distinct(flatten([
        for repo in var.repositories : [
          for topic in coalesce(repo.github_repo_topics, []) :
          lower(topic) if contains([
            "network-policy", "security-groups", "nacl",
            "firewall", "waf", "ddos-protection"
          ], lower(topic))
        ]
      ]))
    }

    data_protection = {
      encryption_tools = distinct(flatten([
        for repo in var.repositories : [
          for topic in coalesce(repo.github_repo_topics, []) :
          lower(topic) if contains([
            "pgp", "gpg", "age-encryption",
            "full-disk-encryption", "dm-crypt",
            "luks", "cryptsetup"
          ], lower(topic))
        ]
      ]))
      backup_tools = distinct(flatten([
        for repo in var.repositories : [
          for topic in coalesce(repo.github_repo_topics, []) :
          lower(topic) if contains([
            "velero", "restic", "borg",
            "backblaze", "rclone", "rsync",
            "duplicity", "bacula"
          ], lower(topic))
        ]
      ]))
      data_lifecycle = distinct(flatten([
        for repo in var.repositories : [
          for topic in coalesce(repo.github_repo_topics, []) :
          lower(topic) if contains([
            "data-retention", "data-lifecycle",
            "archival", "data-deletion",
            "data-classification"
          ], lower(topic))
        ]
      ]))
    }
  }

  # Enhanced Copilot instructions with new analysis
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
       - Repository organization: ${join(", ", [for repo in var.repositories : repo.repo_org])}
       ${local.repo_analysis.templating.uses_templates ? "- Uses repository templates from: ${join(", ", local.repo_analysis.templating.template_sources)}" : ""}
       ${local.repo_analysis.templating.is_template ? "- Contains template repositories for reuse" : ""}

    2. Code Review Process:
       ${local.repo_analysis.review_requirements.required ? <<-EOT
         - Pull request reviews are mandatory
         - Minimum of ${local.repo_analysis.review_requirements.min_reviewers} reviewer(s) required
         - Code owner approval is ${local.repo_analysis.review_requirements.codeowners ? "required" : "optional"}
         - Stale reviews are ${local.repo_analysis.review_requirements.dismiss_stale ? "automatically dismissed" : "preserved"}
         - Branch protection rules ${local.repo_analysis.review_requirements.enforce_admins ? "apply to" : "exclude"} administrators
         ${length(local.repo_analysis.branch_protection.status_checks) > 0 ? "- Required status checks: ${join(", ", local.repo_analysis.branch_protection.status_checks)}" : ""}
         ${local.repo_analysis.branch_protection.strict_updates ? "- Branches must be up-to-date before merging" : ""}
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
    ${length(local.repo_analysis.development_standards.languages) > 0 ? <<-EOT
    1. Programming Languages:
       - Primary languages: ${join(", ", local.repo_analysis.development_standards.languages)}
       - Follow language-specific best practices and style guides
    EOT
    : ""}

    ${length(local.repo_analysis.development_standards.frameworks) > 0 ? <<-EOT
    2. Frameworks:
       - Used frameworks: ${join(", ", local.repo_analysis.development_standards.frameworks)}
       - Follow framework-specific conventions and documentation
    EOT
    : ""}

    3. Testing Requirements:
       ${local.repo_analysis.development_standards.testing_required ? <<-EOT
       - Testing is mandatory
       - Tests must pass before merging
       - Follow testing best practices for each language/framework
       EOT
       : "- Testing requirements not specified"}

    4. CI/CD:
       - Using ${local.repo_analysis.development_standards.ci_tool}
       ${local.repo_analysis.branch_protection.status_checks != null ? "- Status checks must pass: ${join(", ", local.repo_analysis.branch_protection.status_checks)}" : ""}

    ## Code Quality Standards
    
    1. Static Analysis:
       ${local.repo_analysis.code_quality.linting_required ? <<-EOT
       - Code linting is mandatory
       - Use project-specific linting rules
       - Fix all linting issues before committing
       EOT
       : "- No specific linting requirements defined"}
       
    2. Code Formatting:
       ${length(local.repo_analysis.code_quality.formatting_tools) > 0 ? <<-EOT
       - Use standard formatters: ${join(", ", local.repo_analysis.code_quality.formatting_tools)}
       - Format code before committing
       - Follow team-wide formatting conventions
       EOT
       : "- Follow language-specific formatting conventions"}

    3. Type Safety:
       ${local.repo_analysis.code_quality.type_safety ? <<-EOT
       - Strong typing is enforced
       - Type definitions must be complete and accurate
       - Avoid using 'any' or equivalent loose types
       EOT
       : "- Follow language-specific type safety practices"}

    4. Documentation:
       ${local.repo_analysis.code_quality.documentation_required ? <<-EOT
       - Documentation is required
       - Keep documentation up-to-date with changes
       - Include examples in documentation
       - Document complex logic and important decisions
       EOT
       : "- Document important changes and features"}

    ## Infrastructure as Code Standards
    ${length(local.repo_analysis.infrastructure_patterns.iac_tools) > 0 ? <<-EOT
    1. IaC Tools:
       - Primary tools: ${join(", ", local.repo_analysis.infrastructure_patterns.iac_tools)}
       - Follow tool-specific best practices and style guides
       ${local.repo_analysis.infrastructure_patterns.uses_modules ? "- Use modular design patterns" : ""}
    EOT
    : ""}

    ${length(local.repo_analysis.infrastructure_patterns.cloud_providers) > 0 ? <<-EOT
    2. Cloud Providers:
       - Target platforms: ${join(", ", local.repo_analysis.infrastructure_patterns.cloud_providers)}
       - Follow cloud-specific security best practices
       - Use provider-recommended patterns
    EOT
    : ""}

    ${local.repo_analysis.infrastructure_patterns.has_terraform ? <<-EOT
    3. Terraform Standards:
       - Use consistent formatting (terraform fmt)
       - Document all variables and outputs
       - Use version constraints for providers
       - Keep state files secure
       - Use workspaces appropriately
       - Follow standard module structure
    EOT
    : ""}

    ${local.repo_analysis.infrastructure_patterns.has_kubernetes ? <<-EOT
    4. Kubernetes Standards:
       - Follow Kubernetes best practices
       - Use namespaces appropriately
       - Implement resource limits
       - Configure health checks
       - Use appropriate security contexts
       - Version all manifests
    EOT
    : ""}

    ${local.repo_analysis.infrastructure_patterns.deployment_environment ? <<-EOT
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
    ${local.repo_analysis.compliance_patterns.data_protection.encryption_required ? <<-EOT
    1. Data Encryption:
       - Use encryption for data at rest
       - Implement encryption in transit
       - Follow key management best practices
       - Document encryption procedures
    EOT
    : ""}

    ${length(local.repo_analysis.compliance_patterns.compliance_frameworks) > 0 ? <<-EOT
    2. Compliance Requirements:
       - Framework(s): ${join(", ", local.repo_analysis.compliance_patterns.compliance_frameworks)}
       - Follow framework-specific controls
       - Maintain compliance documentation
       - Regular compliance audits
    EOT
    : ""}

    ${local.repo_analysis.compliance_patterns.data_protection.audit_logging ? <<-EOT
    3. Audit and Logging:
       - Implement comprehensive logging
       - Maintain audit trails
       - Secure log storage
       - Regular log reviews
    EOT
    : ""}

    ${local.repo_analysis.compliance_patterns.data_protection.backup_configured ? <<-EOT
    4. Backup and Recovery:
       - Regular backup procedures
       - Test recovery processes
       - Document backup strategy
       - Verify backup integrity
    EOT
    : ""}

    ${local.repo_analysis.compliance_patterns.monitoring_required ? <<-EOT
    5. Monitoring and Alerting:
       - Set up comprehensive monitoring
       - Define alert thresholds
       - Create response procedures
       - Regular monitoring review
    EOT
    : ""}

    ## Deployment and Release Management
    ${length(local.repo_analysis.deployment_patterns.strategies) > 0 ? <<-EOT
    1. Deployment Strategies:
       - Using: ${join(", ", local.repo_analysis.deployment_patterns.strategies)}
       - Document deployment procedures
       - Include rollback plans
       - Test deployment processes
    EOT
    : ""}

    ${length(local.repo_analysis.deployment_patterns.ci_cd_tools) > 0 ? <<-EOT
    2. CI/CD Pipeline:
       - Tools: ${join(", ", local.repo_analysis.deployment_patterns.ci_cd_tools)}
       - Maintain pipeline as code
       - Include automated tests
       - Define quality gates
    EOT
    : ""}

    ${local.repo_analysis.deployment_patterns.uses_gitops ? <<-EOT
    3. GitOps Practices:
       - Use declarative configurations
       - Maintain desired state in Git
       - Automate reconciliation
       - Document drift detection
    EOT
    : ""}

    ${local.repo_analysis.deployment_patterns.feature_flags ? <<-EOT
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
    ${local.repo_analysis.module_patterns.is_module ? <<-EOT
    1. Module Structure:
       - Follow standard Terraform module layout
       - Use consistent file naming:
         * main.tf - Primary module logic
         * variables.tf - Input definitions
         * outputs.tf - Output definitions
         * versions.tf - Version constraints
       - Include README.md with usage examples
       - Document all variables and outputs
       ${length(local.repo_analysis.module_patterns.module_types) > 0 ? "- Module types: ${join(", ", local.repo_analysis.module_patterns.module_types)}" : ""}

    2. Module Development:
       - Use consistent variable naming
       - Implement proper validation rules
       - Add default values where appropriate
       - Include type constraints
       - Handle optional variables properly
       ${length(local.repo_analysis.module_patterns.testing_frameworks) > 0 ? "- Testing frameworks: ${join(", ", local.repo_analysis.module_patterns.testing_frameworks)}" : ""}

    3. Module Documentation:
       ${length(local.repo_analysis.module_patterns.documentation_tools) > 0 ? "- Documentation tools: ${join(", ", local.repo_analysis.module_patterns.documentation_tools)}" : "- Use terraform-docs for documentation"}
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
    ${length(local.repo_analysis.security_tooling.secret_managers) > 0 ? <<-EOT
    1. Secret Management Solutions:
       - Primary tools: ${join(", ", local.repo_analysis.security_tooling.secret_managers)}
       - Follow secret management best practices
       - Use appropriate authentication methods
       - Implement secret rotation
    EOT
    : ""}

    ${local.repo_analysis.security_tooling.vault_integration ? <<-EOT
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

    ${local.repo_analysis.security_tooling.cloud_key_management.aws ? <<-EOT
    3. AWS Key Management:
       - Use AWS KMS for encryption
       - Implement proper IAM roles
       - Enable CloudTrail logging
       - Use customer managed keys
       - Follow AWS security best practices
       - Enable automatic key rotation
    EOT
    : ""}

    ${local.repo_analysis.security_tooling.cloud_key_management.azure ? <<-EOT
    4. Azure Key Vault:
       - Use managed identities
       - Enable soft-delete and purge protection
       - Configure access policies
       - Enable monitoring and diagnostics
       - Follow Azure security baselines
       - Use key rotation policies
    EOT
    : ""}

    ${local.repo_analysis.security_tooling.cloud_key_management.gcp ? <<-EOT
    5. Google Cloud KMS:
       - Use service accounts appropriately
       - Enable audit logging
       - Implement key rotation
       - Follow GCP security best practices
       - Use CMEK where appropriate
    EOT
    : ""}

    ${length(local.repo_analysis.security_tooling.security_tools) > 0 ? <<-EOT
    6. Additional Security Tools:
       - Configured tools: ${join(", ", local.repo_analysis.security_tooling.security_tools)}
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
    ${length(local.repo_analysis.security_certification.frameworks) > 0 ? <<-EOT
    1. Compliance Frameworks:
       - Required certifications: ${join(", ", local.repo_analysis.security_certification.frameworks)}
       - Implement required controls
       - Regular compliance audits
       - Maintain documentation
    EOT
    : ""}

    ${local.repo_analysis.security_certification.requires_audit ? <<-EOT
    2. Audit Requirements:
       - Implement audit logging
       - Track system changes
       - Monitor access patterns
       - Regular audit reviews
       - Maintain audit trail
    EOT
    : ""}

    ${length(local.repo_analysis.security_certification.security_controls) > 0 ? <<-EOT
    3. Security Controls:
       - Implemented controls: ${join(", ", local.repo_analysis.security_certification.security_controls)}
       - Follow control specifications
       - Regular control testing
       - Document exceptions
    EOT
    : ""}

    ## Container Security Standards
    ${length(local.repo_analysis.container_security.scanning_tools) > 0 ? <<-EOT
    1. Container Scanning:
       - Use tools: ${join(", ", local.repo_analysis.container_security.scanning_tools)}
       - Scan base images
       - Check for vulnerabilities
       - Monitor dependencies
       - Regular rescanning
    EOT
    : ""}

    ${length(local.repo_analysis.container_security.runtime_security) > 0 ? <<-EOT
    2. Runtime Protection:
       - Implement: ${join(", ", local.repo_analysis.container_security.runtime_security)}
       - Monitor container behavior
       - Enforce security policies
       - Alert on violations
    EOT
    : ""}

    ${length(local.repo_analysis.container_security.registry_security) > 0 ? <<-EOT
    3. Registry Security:
       - Use: ${join(", ", local.repo_analysis.container_security.registry_security)}
       - Sign container images
       - Verify signatures
       - Enforce trusted sources
    EOT
    : ""}

    4. Container Best Practices:
       ${local.repo_analysis.container_security.uses_distroless ? "- Use distroless base images" : "- Minimize base image size"}
       - Keep base images updated
       - Run as non-root
       - Use read-only root filesystem
       - Implement resource limits
       - Scan during CI/CD

    ## Security Scanning and Analysis
    ${length(local.repo_analysis.security_scanning.sast_tools) > 0 ? <<-EOT
    1. Static Application Security Testing:
       - Tools in use: ${join(", ", local.repo_analysis.security_scanning.sast_tools)}
       - Scan during code reviews
       - Fix high-severity issues
       - Track security metrics
       - Regular baseline updates
    EOT
    : ""}

    ${length(local.repo_analysis.security_scanning.dast_tools) > 0 ? <<-EOT
    2. Dynamic Application Security Testing:
       - Tools configured: ${join(", ", local.repo_analysis.security_scanning.dast_tools)}
       - Test in staging environment
       - Regular security assessments
       - Monitor for vulnerabilities
       - Document findings
    EOT
    : ""}

    ${length(local.repo_analysis.security_scanning.dependency_scanning) > 0 ? <<-EOT
    3. Dependency Management:
       - Using: ${join(", ", local.repo_analysis.security_scanning.dependency_scanning)}
       - Regular dependency updates
       - Vulnerability monitoring
       - License compliance
       - Update scheduling
    EOT
    : ""}

    ${length(local.repo_analysis.security_scanning.compliance_tools) > 0 ? <<-EOT
    4. Compliance Scanning:
       - Tools enabled: ${join(", ", local.repo_analysis.security_scanning.compliance_tools)}
       - Regular compliance checks
       - Policy enforcement
       - Remediation tracking
       - Compliance reporting
    EOT
    : ""}

    ${length(local.repo_analysis.security_scanning.reporting_tools) > 0 ? <<-EOT
    5. Security Reporting:
       - Platforms: ${join(", ", local.repo_analysis.security_scanning.reporting_tools)}
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
    ${length(local.repo_analysis.network_security.network_tools) > 0 ? <<-EOT
    1. Network Infrastructure:
       - Tools in use: ${join(", ", local.repo_analysis.network_security.network_tools)}
       - Implement network segmentation
       - Use secure communication
       - Monitor network traffic
       - Regular security audits
    EOT
    : ""}

    ${local.repo_analysis.network_security.zero_trust ? <<-EOT
    2. Zero Trust Architecture:
       - Implement zero trust principles
       - Verify all connections
       - Use strong authentication
       - Limit access scope
       - Monitor all traffic
    EOT
    : ""}

    ${local.repo_analysis.network_security.service_mesh ? <<-EOT
    3. Service Mesh Security:
       - Enforce mutual TLS
       - Implement access policies
       - Monitor service traffic
       - Secure service discovery
       - Regular mesh updates
    EOT
    : ""}

    ${length(local.repo_analysis.network_security.network_policies) > 0 ? <<-EOT
    4. Network Policies:
       - Implemented: ${join(", ", local.repo_analysis.network_security.network_policies)}
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
    ${length(local.repo_analysis.data_protection.encryption_tools) > 0 ? <<-EOT
    1. Data Encryption:
       - Tools in use: ${join(", ", local.repo_analysis.data_protection.encryption_tools)}
       - Implement encryption at rest
       - Use strong encryption algorithms
       - Secure key management
       - Regular key rotation
    EOT
    : ""}

    ${length(local.repo_analysis.data_protection.backup_tools) > 0 ? <<-EOT
    2. Backup Solutions:
       - Using: ${join(", ", local.repo_analysis.data_protection.backup_tools)}
       - Regular backup schedule
       - Verify backup integrity
       - Test restoration process
       - Secure backup storage
    EOT
    : ""}

    ${length(local.repo_analysis.data_protection.data_lifecycle) > 0 ? <<-EOT
    3. Data Lifecycle Management:
       - Implement: ${join(", ", local.repo_analysis.data_protection.data_lifecycle)}
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

  base_init_script = templatefile("${path.module}/templates/init.sh.tpl", {
    project_name = var.project_name,
    repositories  = [for repo in module.project_repos : repo.ssh_clone_url]
  })
  init_script_content = var.initialization_script != null ? "${local.base_init_script}\n\n${var.initialization_script.content}" : local.base_init_script

  master_repo = {
    name                    = var.project_name
    github_repo_description = "Master repository for ${var.project_name} project"
    github_repo_topics      = ["project-master"]
    force_name              = try(var.repositories[0].force_name, true)
    managed_extra_files = concat([
      {
        path    = ".github/prompts/project-setup.prompt.md"
        content = var.project_prompt
      },
      {
        path    = ".github/copilot-instructions.md"
        content = coalesce(var.copilot_instructions, local.generated_copilot_instructions)
      },
      {
        path = "${var.project_name}.code-workspace"
        content = jsonencode({
          folders = local.workspace_folders
        })
      },
      {
        path = ".init.sh"
        content = local.init_script_content
      }
    ], coalesce(try(var.repositories[0].managed_extra_files, []), []))
  }

  master_repo_config = merge(
    try(var.repositories[0], {}),
    local.master_repo
  )
}

module "master_repo" {
  source = "../terraform-github-repo"

  name                                    = local.master_repo_config.name
  repo_org                                = try(local.master_repo_config.repo_org, null)
  github_repo_description                 = local.master_repo_config.github_repo_description
  github_repo_topics                      = local.master_repo_config.github_repo_topics
  github_push_restrictions                = try(local.master_repo_config.github_push_restrictions, [])
  github_is_private                       = try(local.master_repo_config.github_is_private, true)
  github_auto_init                        = try(local.master_repo_config.github_auto_init, true)
  github_allow_merge_commit               = try(local.master_repo_config.github_allow_merge_commit, false)
  github_allow_squash_merge               = try(local.master_repo_config.github_allow_squash_merge, true)
  github_allow_rebase_merge               = try(local.master_repo_config.github_allow_rebase_merge, false)
  github_delete_branch_on_merge           = try(local.master_repo_config.github_delete_branch_on_merge, true)
  github_has_projects                     = try(local.master_repo_config.github_has_projects, true)
  github_has_issues                       = try(local.master_repo_config.github_has_issues, false)
  github_has_wiki                         = try(local.master_repo_config.github_has_wiki, true)
  github_default_branch                   = try(local.master_repo_config.github_default_branch, "main")
  github_required_approving_review_count  = try(local.master_repo_config.github_required_approving_review_count, 1)
  github_require_code_owner_reviews       = try(local.master_repo_config.github_require_code_owner_reviews, true)
  github_dismiss_stale_reviews            = try(local.master_repo_config.github_dismiss_stale_reviews, true)
  github_enforce_admins_branch_protection = try(local.master_repo_config.github_enforce_admins_branch_protection, true)
  additional_codeowners                   = try(local.master_repo_config.additional_codeowners, [])
  prefix                                  = try(local.master_repo_config.prefix, null)
  force_name                              = try(local.master_repo_config.force_name, false)
  github_org_teams                        = try(local.master_repo_config.github_org_teams, null)
  template_repo_org                       = try(local.master_repo_config.template_repo_org, null)
  template_repo                           = try(local.master_repo_config.template_repo, null)
  is_template                             = try(local.master_repo_config.is_template, false)
  admin_teams                             = try(local.master_repo_config.admin_teams, [])
  required_status_checks                  = try(local.master_repo_config.required_status_checks, null)
  archived                                = try(local.master_repo_config.archived, false)
  secrets                                 = try(local.master_repo_config.secrets, [])
  vars                                    = try(local.master_repo_config.vars, [])
  extra_files                             = try(local.master_repo_config.extra_files, [])
  managed_extra_files                     = local.master_repo_config.managed_extra_files
  pull_request_bypassers                  = try(local.master_repo_config.pull_request_bypassers, [])
  create_codeowners                       = try(local.master_repo_config.create_codeowners, true)
  enforce_prs                             = try(local.master_repo_config.enforce_prs, var.enforce_prs)
  collaborators                           = try(local.master_repo_config.collaborators, {})
  archive_on_destroy                      = try(local.master_repo_config.archive_on_destroy, true)
  vulnerability_alerts                    = try(local.master_repo_config.vulnerability_alerts, false)
  gitignore_template                      = try(local.master_repo_config.gitignore_template, null)
  homepage_url                            = try(local.master_repo_config.homepage_url, null)
  security_and_analysis                   = try(local.master_repo_config.security_and_analysis, null)
}

module "project_repos" {
  source   = "../terraform-github-repo"
  for_each = { for idx, repo in var.repositories : repo.name => repo }

  name                                    = each.value.name
  repo_org                                = each.value.repo_org
  github_repo_description                 = each.value.github_repo_description
  github_repo_topics                      = each.value.github_repo_topics
  github_push_restrictions                = each.value.github_push_restrictions
  github_is_private                       = each.value.github_is_private
  github_auto_init                        = each.value.github_auto_init
  github_allow_merge_commit               = each.value.github_allow_merge_commit
  github_allow_squash_merge               = each.value.github_allow_squash_merge
  github_allow_rebase_merge               = each.value.github_allow_rebase_merge
  github_delete_branch_on_merge           = each.value.github_delete_branch_on_merge
  github_has_projects                     = each.value.github_has_projects
  github_has_issues                       = each.value.github_has_issues
  github_has_wiki                         = each.value.github_has_wiki
  github_default_branch                   = each.value.github_default_branch
  github_required_approving_review_count  = each.value.github_required_approving_review_count
  github_require_code_owner_reviews       = each.value.github_require_code_owner_reviews
  github_dismiss_stale_reviews            = each.value.github_dismiss_stale_reviews
  github_enforce_admins_branch_protection = each.value.github_enforce_admins_branch_protection
  additional_codeowners                   = each.value.additional_codeowners
  prefix                                  = each.value.prefix
  force_name                              = each.value.force_name
  github_org_teams                        = each.value.github_org_teams
  template_repo_org                       = each.value.template_repo_org
  template_repo                           = each.value.template_repo
  is_template                             = each.value.is_template
  admin_teams                             = each.value.admin_teams
  required_status_checks                  = each.value.required_status_checks
  archived                                = each.value.archived
  secrets                                 = each.value.secrets
  vars                                    = each.value.vars
  extra_files                             = each.value.extra_files
  managed_extra_files = concat(
    coalesce(each.value.managed_extra_files, []),
    [{
      path    = ".github/prompts/repo-setup.prompt.md"
      content = each.value.prompt
    }]
  )
  pull_request_bypassers = each.value.pull_request_bypassers
  create_codeowners      = each.value.create_codeowners
  enforce_prs            = try(each.value.enforce_prs, var.enforce_prs)
  collaborators          = each.value.collaborators
  archive_on_destroy     = each.value.archive_on_destroy
  vulnerability_alerts   = each.value.vulnerability_alerts
  gitignore_template     = each.value.gitignore_template
  homepage_url           = each.value.homepage_url
  security_and_analysis  = each.value.security_and_analysis
}
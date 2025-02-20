terraform {
  backend "gcs" {
    bucket = "hpw-terraform-state"
    prefix = "github-projects/terraform-workspace"
  }

  required_providers {
    github = {
      source  = "integrations/github"
    }
  }
}

module "terraform_workspace" {
  source = "../../"

  project_name    = "aws-platform"
  repo_org        = "my-org"
  project_prompt  = "AWS infrastructure modules and platform configuration"

  repositories = [
    {
      name        = "platform-core"
      description = "Core AWS platform configuration"
      topics      = ["terraform", "aws", "infrastructure"]
      gitignore_template = "Terraform"
      prompt      = "Core AWS platform including VPC, networking, and shared services"
      branch_protection = {
        required_status_checks = {
          strict = true
          contexts = [
            "terraform-fmt",
            "terraform-validate",
            "tflint",
            "checkov",
            "infracost"
          ]
        }
        required_approving_review_count = 2
      }
      has_wiki = true
      has_issues = true
    },
    {
      name        = "module-eks"
      description = "EKS cluster module"
      topics      = ["terraform", "aws", "eks", "kubernetes"]
      gitignore_template = "Terraform"
      prompt      = "Reusable module for EKS cluster deployment with best practices"
      branch_protection = {
        required_status_checks = {
          contexts = ["terraform-fmt", "terraform-docs", "tflint"]
        }
      }
    },
    {
      name        = "module-rds"
      description = "RDS database module"
      topics      = ["terraform", "aws", "rds", "database"]
      gitignore_template = "Terraform"
      prompt      = "Reusable module for RDS database deployment with security best practices"
      branch_protection = {
        required_status_checks = {
          contexts = ["terraform-fmt", "terraform-docs", "tflint"]
        }
      }
    },
    {
      name        = "environments"
      description = "Environment-specific configurations"
      topics      = ["terraform", "aws", "environments"]
      gitignore_template = "Terraform"
      prompt      = "Environment-specific Terraform configurations for development, staging, and production"
      branch_protection = {
        required_status_checks = {
          contexts = ["terraform-plan"]
        }
        required_approving_review_count = 2
      }
    }
  ]

  base_repository = {
    description = "AWS Platform Infrastructure"
    topics      = ["project-base", "terraform", "aws", "infrastructure"]
    branch_protection = {
      required_linear_history = true
      required_status_checks = {
        strict = true
        contexts = ["terraform-fmt"]
      }
      require_code_owner_reviews = true
      required_approving_review_count = 2
    }
    pages = {
      branch = "gh-pages"
      path   = "/docs"
    }
    extra_files = [
      {
        path    = ".terraform-docs.yml"
        content = <<-EOT
formatter: markdown table
output:
  file: README.md
  mode: inject
  template: |-
    <!-- BEGIN_TF_DOCS -->
    {{ .Content }}
    <!-- END_TF_DOCS -->
sort:
  enabled: true
  by: required
settings:
  anchor: true
  color: true
  default: true
  description: false
  escape: true
  hide-empty: false
  html: true
  indent: 2
  lockfile: true
  required: true
  sensitive: true
  type: true
EOT
      }
    ]
  }

  environments = {
    "environments" = [
      {
        name = "development"
        vars = [
          {
            name  = "AWS_REGION"
            value = "us-west-2"
          }
        ]
      },
      {
        name = "production"
        deployment_branch_policy = {
          protected_branches = true
        }
        reviewers = {
          teams = ["platform-team", "security-team"]
        }
        vars = [
          {
            name  = "AWS_REGION"
            value = "us-east-1"
          }
        ]
      }
    ]
  }
}
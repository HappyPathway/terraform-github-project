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
  repo_org        = "HappyPathway"
  project_prompt  = "AWS infrastructure modules and platform configuration"
  
  archive_on_destroy = false

  repositories = [
    {
      name        = "platform-core"
      description = "Core AWS platform configuration"
      topics      = ["terraform", "aws", "infrastructure"]
      gitignore_template = "Terraform"
      github_is_private = false
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
      github_is_private = false
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
      github_is_private = false
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
      github_is_private = false
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
    visibility  = "public"
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
        content = file("${path.module}/terraform-docs.yml")
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

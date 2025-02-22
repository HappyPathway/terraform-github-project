terraform {
  backend "gcs" {
    bucket = "hpw-terraform-state"
    prefix = "github-projects/multi-tier-webapp"
  }

  required_providers {
    github = {
      source = "integrations/github"
    }
  }
}

module "github_project" {
  source = "../../"

  project_name   = "e-commerce-platform"
  repo_org       = "my-org"
  project_prompt = "E-commerce platform with React frontend, Node.js API, and PostgreSQL database"
  repositories = [
    {
      name = "frontend"
      github_repo_topics = [
        "typescript", "react", "jest",
        "docker", "nginx"
      ]
      prompt = "React TypeScript frontend application"
    },
    {
      name = "api"
      github_repo_topics = [
        "nodejs", "express", "jest",
        "docker", "swagger"
      ]
      prompt = "Node.js API service"
    },
    {
      name = "database"
      github_repo_topics = [
        "postgresql", "flyway",
        "terraform", "aws"
      ]
      prompt = "Database infrastructure and migrations"
    }
  ]

  # Security configuration
  security_config = {
    enable_security_scanning = true
    security_frameworks      = ["SOC2", "GDPR"]

    container_security_config = {
      scanning_tools    = ["trivy", "snyk"]
      runtime_security  = ["falco"]
      registry_security = ["harbor"]
      uses_distroless   = true
    }
  }

  # Development configuration
  development_config = {
    testing_requirements = {
      required           = true
      coverage_threshold = 85
    }

    ci_cd_config = {
      ci_cd_tools = ["github-actions"]
      required_status_checks = [
        "build",
        "test",
        "lint",
        "security-scan"
      ]
    }
  }

  # Infrastructure configuration
  infrastructure_config = {
    iac_config = {
      iac_tools           = ["terraform"]
      cloud_providers     = ["aws"]
      documentation_tools = ["terraform-docs"]
      testing_frameworks  = ["terratest"]
    }
  }

  # Quality configuration
  quality_config = {
    linting_required       = true
    type_safety            = true
    documentation_required = true

    formatting_tools = [
      "prettier",
      "eslint"
    ]

    linting_tools = [
      "eslint",
      "tslint"
    ]

    documentation_tools = [
      "typedoc",
      "swagger"
    ]
  }
}
terraform {
  backend "gcs" {
    bucket = "hpw-terraform-state"
    prefix = "github-projects/minimal"
  }

  required_providers {
    github = {
      source = "integrations/github"
    }
  }
}

module "github_project" {
  source = "../../"

  project_name   = "minimal-project"
  repo_org       = "my-org"
  project_prompt = "Minimal project with a single Python FastAPI service"
  repositories = [
    {
      name               = "service"
      github_repo_topics = ["python", "fastapi", "pytest"]
      prompt             = "Python FastAPI service"
    }
  ]

  # Security configuration using security module
  security_config = {
    enable_security_scanning = true
    security_frameworks      = ["SOC2"]
    container_security_config = {
      scanning_tools = ["trivy"]
    }
  }

  # Development configuration using development module
  development_config = {
    testing_requirements = {
      required           = true
      coverage_threshold = 80
    }
    ci_cd_config = {
      ci_cd_tools            = ["github-actions"]
      required_status_checks = ["test", "lint"]
    }
  }

  # Infrastructure configuration using infrastructure module
  infrastructure_config = {
    iac_config = {
      iac_tools           = ["terraform"]
      documentation_tools = ["terraform-docs"]
    }
  }

  # Quality configuration using quality module
  quality_config = {
    linting_required       = true
    type_safety            = true
    documentation_required = true
    formatting_tools       = ["black", "isort"]
    linting_tools          = ["flake8", "pylint"]
  }
}
terraform {
  required_providers {
    github = {
      source  = "integrations/github"
      version = "~> 5.0"
    }
  }
}

provider "github" {}

locals {
  # Define infrastructure module patterns
  infra_modules = [
    {
      name   = "compute"
      prompt = "Infrastructure module for managing compute resources"
      topics = ["terraform", "infra", "compute"]
    },
    {
      name   = "networking"
      prompt = "Infrastructure module for network configuration"
      topics = ["terraform", "infra", "networking"]
    },
    {
      name   = "storage"
      prompt = "Infrastructure module for storage resources"
      topics = ["terraform", "infra", "storage"]
    },
    {
      name   = "monitoring"
      prompt = "Infrastructure module for monitoring and logging"
      topics = ["terraform", "infra", "monitoring"]
    }
  ]
}

module "github_project" {
  source = "../.."

  # Required variables with infrastructure focus
  repo_org       = var.repo_org
  project_name   = var.project_name
  project_prompt = var.project_prompt

  # Base repository configuration
  base_repository = {
    visibility  = "public"
    description = "Infrastructure modules for cloud resource management"
    topics      = ["terraform", "infrastructure", "iac"]
  }

  # Generate infrastructure module repositories
  repositories = [
    for module in local.infra_modules : {
      name       = "terraform-${var.cloud_provider}-${module.name}"
      prompt     = module.prompt
      topics     = module.topics
      visibility = "public" # Required without GitHub Pro
    }
  ]

  # Infrastructure-focused development configuration
  vs_code_workspace = {
    settings = {
      "editor.formatOnSave" : true,
      "files.trimTrailingWhitespace" : true
    }
    extensions = {
      recommended = [
        "hashicorp.terraform",
        "github.copilot",
        "github.copilot-chat"
      ]
    }
    tasks = [
      {
        name    = "terraform-fmt"
        command = "terraform fmt -recursive"
      }
    ]
  }

  # Infrastructure configuration
  infrastructure_config = {
    iac_config = {
      iac_tools           = ["terraform"]
      cloud_providers     = [var.cloud_provider]
      documentation_tools = ["terraform-docs"]
      testing_frameworks  = ["terratest"]
    }
  }
}
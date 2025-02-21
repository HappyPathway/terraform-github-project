terraform {
  backend "gcs" {
    bucket = "hpw-terraform-state"
    prefix = "github-projects/java-microservices"
  }

  required_providers {
    github = {
      source  = "integrations/github"
    }
  }
}


module "java_microservices" {
  source = "../../"

  project_name    = "retail-platform"
  repo_org        = "HappyPathway"
  project_prompt  = "Java Spring Boot microservices platform for retail operations"

  repositories = [
    {
      name        = "product-service"
      description = "Product catalog microservice"
      topics      = ["java", "spring-boot", "microservice"]
      gitignore_template = "Java"
      prompt      = "Spring Boot microservice managing product catalog"
      github_is_private = false
      branch_protection = {
        required_status_checks = {
          strict = true
          contexts = ["maven-build", "integration-tests", "sonarqube"]
        }
        require_code_owner_reviews = true
        required_approving_review_count = 2
      }
    },
    {
      name        = "order-service"
      description = "Order processing microservice"
      topics      = ["java", "spring-boot", "microservice"]
      gitignore_template = "Java"
      prompt      = "Spring Boot microservice for order processing"
      github_is_private = false
      branch_protection = {
        required_status_checks = {
          contexts = ["maven-build", "integration-tests"]
        }
      }
    },
    {
      name        = "api-gateway"
      description = "API Gateway service"
      topics      = ["java", "spring-cloud-gateway"]
      gitignore_template = "Java"
      prompt      = "Spring Cloud Gateway service for routing and cross-cutting concerns"
      github_is_private = false
    },
    {
      name        = "shared-library"
      description = "Shared utilities and models"
      topics      = ["java", "library"]
      gitignore_template = "Java"
      prompt      = "Shared Java library for common utilities and domain models"
      is_template = false
      github_is_private = false
    }
  ]

  base_repository = {
    description = "Retail Platform Microservices"
    topics      = ["project-base", "java", "spring-boot", "microservices"]
    visibility  = "public"
    branch_protection = {
      required_linear_history = true
      require_code_owner_reviews = true
      required_approving_review_count = 2
      dismiss_stale_reviews = true
    }
  }

  environments = {
    "product-service" = [
      {
        name = "development"
        vars = [
          {
            name  = "SPRING_PROFILES_ACTIVE"
            value = "dev"
          }
        ]
      },
      {
        name = "staging"
        reviewers = {
          teams = ["platform-team"]
        }
        vars = [
          {
            name  = "SPRING_PROFILES_ACTIVE"
            value = "staging"
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
            name  = "SPRING_PROFILES_ACTIVE"
            value = "prod"
          }
        ]
      }
    ]
  }
}
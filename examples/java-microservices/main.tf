module "java_microservices" {
  source = "../../"

  project_name    = "retail-platform"
  repo_org        = "my-org"
  project_prompt  = "Java Spring Boot microservices platform for retail operations"

  repositories = [
    {
      name        = "product-service"
      description = "Product catalog microservice"
      topics      = ["java", "spring-boot", "microservice"]
      gitignore_template = "Java"
      prompt      = "Spring Boot microservice managing product catalog"
      branch_protection = {
        required_status_checks = {
          strict = true
          contexts = ["maven-build", "integration-tests", "sonarqube"]
        }
        require_code_owner_reviews = true
        required_approving_review_count = 2
      }
      security_and_analysis = {
        advanced_security = {
          status = "enabled"
        }
      }
    },
    {
      name        = "order-service"
      description = "Order processing microservice"
      topics      = ["java", "spring-boot", "microservice"]
      gitignore_template = "Java"
      prompt      = "Spring Boot microservice for order processing"
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
    },
    {
      name        = "shared-library"
      description = "Shared utilities and models"
      topics      = ["java", "library"]
      gitignore_template = "Java"
      prompt      = "Shared Java library for common utilities and domain models"
      is_template = false
    }
  ]

  base_repository = {
    description = "Retail Platform Microservices"
    topics      = ["project-base", "java", "spring-boot", "microservices"]
    branch_protection = {
      required_linear_history = true
      require_code_owner_reviews = true
      required_approving_review_count = 2
      dismiss_stale_reviews = true
    }
    security_and_analysis = {
      advanced_security = {
        status = "enabled"
      }
      secret_scanning = {
        status = "enabled"
      }
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
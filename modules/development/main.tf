module "standards" {
  source = "./modules/standards"
  
  repositories = var.repositories
  testing_requirements = var.testing_requirements
}

module "deployment" {
  source = "./modules/deployment"
  
  repositories = var.repositories
  ci_cd_config = var.ci_cd_config
}

locals {
  development_config = {
    standards = module.standards.development_standards
    deployment = module.deployment.deployment_config
  }
}
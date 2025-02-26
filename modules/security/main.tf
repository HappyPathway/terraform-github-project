# Security configuration for repositories
module "container" {
  source                    = "./modules/container"
  repositories              = var.repositories
  container_security_config = var.container_security_config
}

module "network" {
  source       = "./modules/network"
  repositories = var.repositories
}

module "compliance" {
  source              = "./modules/compliance"
  repositories        = var.repositories
  security_frameworks = var.security_frameworks
}
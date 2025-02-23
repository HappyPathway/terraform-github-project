# Development standards module
module "standards" {
  source       = "./modules/standards"
  repositories = var.repositories
}

# Deployment configuration module
module "deployment" {
  source       = "./modules/deployment"
  repositories = var.repositories
}
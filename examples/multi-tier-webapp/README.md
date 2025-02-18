# ACME Shop Project Setup

This is the master repository for the ACME Shop e-commerce platform. The project consists of three main components:
- Frontend (React.js SPA)
- Backend API (Node.js/Express)
- Database (PostgreSQL)

## Project Structure
```
acme-shop/              # Main project repository (you are here)
├── acme-shop-frontend/ # React.js frontend application
├── acme-shop-api/     # Node.js backend API
└── acme-shop-db/      # Database migrations and schemas
```

## Development Guidelines
1. All code changes must go through pull requests
2. Each component has its own repository with specific setup instructions
3. Use conventional commits for all commit messages
4. Keep documentation up to date
5. Follow the defined code style guides in each repository

# Multi-Tier Web Application with AWS Infrastructure

This example demonstrates how to set up a multi-tier web application with infrastructure as code using AWS resources and GitHub repositories.

## Repository Structure

1. **frontend-repo/**
   - React frontend application
   - See `frontend-README.md` for details

2. **api-repo/**
   - Node.js API service
   - See `api-README.md` for details

3. **db-repo/**
   - Database migrations and schemas
   - See `db-README.md` for details

4. **infra-repo/**
   - Infrastructure as Code (Terraform)
   - AWS resources configuration
   - Auto-scaling and load balancing setup

## AWS Infrastructure Setup

### Prerequisites
- AWS CLI configured
- Terraform installed
- Valid AWS credentials with necessary permissions
- Route 53 domain (optional)

### Main Components
1. VPC and Networking
2. Application Load Balancer (ALB)
3. Auto Scaling Groups (ASG)
4. RDS Database
5. Security Groups

### Infrastructure Code Structure (infra-repo)
```
infra-repo/
├── modules/
│   ├── vpc/
│   ├── alb/
│   ├── asg/
│   ├── rds/
│   └── security/
├── environments/
│   ├── dev/
│   ├── staging/
│   └── prod/
└── variables/
    ├── dev.tfvars
    ├── staging.tfvars
    └── prod.tfvars
```

### Auto Scaling Group and ALB Configuration

```hcl
# Example Terraform configuration for ASG and ALB

module "alb" {
  source = "./modules/alb"
  
  name               = "web-alb"
  internal          = false
  vpc_id            = module.vpc.vpc_id
  subnets           = module.vpc.public_subnets
  security_groups   = [module.security.alb_sg_id]
  
  http_tcp_listeners = [
    {
      port               = 80
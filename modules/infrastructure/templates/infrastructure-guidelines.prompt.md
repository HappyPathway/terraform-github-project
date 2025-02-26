# Infrastructure Guidelines for ${repository_name}

## Infrastructure Tools
%{ if length(iac_tools) > 0 ~}
### IaC Tools
%{ for tool in iac_tools ~}
- ${tool}
%{ endfor ~}
%{ endif ~}

## Cloud Providers
%{ if length(cloud_providers) > 0 ~}
The infrastructure is designed to work with:
%{ for provider in cloud_providers ~}
- ${provider}
%{ endfor ~}
%{ endif ~}

%{ if has_kubernetes ~}
## Kubernetes Configuration
This repository includes Kubernetes configurations. Follow these guidelines:
- Use namespaces for isolation
- Apply resource limits
- Follow security best practices
- Use ConfigMaps and Secrets appropriately
%{ endif ~}

## Infrastructure Configuration
%{ if can(iac_config.deployment_environment) ~}
- Deployment Environment: ${iac_config.deployment_environment}
%{ endif ~}
%{ if can(iac_config.resource_naming) ~}
- Resource Naming Convention: ${iac_config.resource_naming}
%{ endif ~}

## Best Practices
1. Use version control for infrastructure code
2. Document all configuration changes
3. Test infrastructure changes in staging
4. Follow least privilege principle
5. Implement proper monitoring and logging
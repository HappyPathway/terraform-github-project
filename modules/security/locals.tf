locals {
  security_scanning         = var.enable_security_scanning
  security_frameworks       = var.security_frameworks
  container_security_config = try(var.container_security_config, {})
  network_security_config   = try(module.network.network_security_config, {})
  compliance_config         = try(module.compliance.compliance_config, {})
}
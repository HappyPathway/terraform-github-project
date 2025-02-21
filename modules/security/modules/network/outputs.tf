output "network_security_config" {
  description = "Network security configuration derived from repository analysis"
  value = {
    network_tools    = local.network_tools
    zero_trust       = local.zero_trust
    service_mesh     = local.service_mesh
    network_policies = local.network_policies
  }
}
# =============================================================================
# Network Module - Outputs
# =============================================================================

output "vnet_id" {
  description = "ID of the Virtual Network"
  value       = azurerm_virtual_network.main.id
}

output "vnet_name" {
  description = "Name of the Virtual Network"
  value       = azurerm_virtual_network.main.name
}

output "subnet_app_gw_id" {
  description = "ID of the Application Gateway subnet"
  value       = azurerm_subnet.app_gw.id
}

output "subnet_vnet_integration_id" {
  description = "ID of the VNet Integration subnet"
  value       = azurerm_subnet.vnet_integration.id
}

output "subnet_private_endpoint_id" {
  description = "ID of the Private Endpoint subnet"
  value       = azurerm_subnet.private_endpoint.id
}

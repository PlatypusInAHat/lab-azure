# =============================================================================
# Application Gateway Module - Outputs
# =============================================================================

output "public_ip_address" {
  description = "Public IP address of the Application Gateway"
  value       = azurerm_public_ip.app_gw.ip_address
}

output "public_ip_fqdn" {
  description = "FQDN of the Application Gateway"
  value       = azurerm_public_ip.app_gw.fqdn
}

output "app_gateway_id" {
  description = "ID of the Application Gateway"
  value       = azurerm_application_gateway.main.id
}

output "app_gateway_name" {
  description = "Name of the Application Gateway"
  value       = azurerm_application_gateway.main.name
}

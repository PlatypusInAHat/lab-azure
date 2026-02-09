# =============================================================================
# App Service Module - Outputs
# =============================================================================

output "app_service_id" {
  description = "ID of the App Service"
  value       = azurerm_linux_web_app.main.id
}

output "app_service_name" {
  description = "Name of the App Service"
  value       = azurerm_linux_web_app.main.name
}

output "default_hostname" {
  description = "Default hostname of the App Service"
  value       = azurerm_linux_web_app.main.default_hostname
}

output "principal_id" {
  description = "Principal ID of the managed identity"
  value       = azurerm_linux_web_app.main.identity[0].principal_id
}

output "private_endpoint_id" {
  description = "ID of the Private Endpoint"
  value       = azurerm_private_endpoint.app_service.id
}

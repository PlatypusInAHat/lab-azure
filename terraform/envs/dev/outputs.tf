# =============================================================================
# Dev Environment - Outputs
# =============================================================================

output "resource_group_name" {
  description = "Resource group name"
  value       = azurerm_resource_group.main.name
}

output "app_gateway_public_ip" {
  description = "Application Gateway public IP"
  value       = module.app_gateway.public_ip_address
}

output "app_gateway_fqdn" {
  description = "Application Gateway FQDN"
  value       = module.app_gateway.public_ip_fqdn
}

output "app_service_name" {
  description = "App Service name"
  value       = module.app_service.app_service_name
}

output "app_service_hostname" {
  description = "App Service hostname"
  value       = module.app_service.default_hostname
}

output "key_vault_name" {
  description = "Key Vault name"
  value       = module.key_vault.key_vault_name
}

output "key_vault_uri" {
  description = "Key Vault URI"
  value       = module.key_vault.key_vault_uri
}

output "sql_server_fqdn" {
  description = "SQL Server FQDN"
  value       = module.sql.sql_server_fqdn
}

output "storage_account_name" {
  description = "Storage Account name"
  value       = module.storage.storage_account_name
}

output "vnet_name" {
  description = "Virtual Network name"
  value       = module.network.vnet_name
}

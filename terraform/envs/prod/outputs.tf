# =============================================================================
# Prod Environment - Outputs
# =============================================================================

output "resource_group_name" {
  value = azurerm_resource_group.main.name
}

output "app_gateway_public_ip" {
  value = module.app_gateway.public_ip_address
}

output "app_gateway_fqdn" {
  value = module.app_gateway.public_ip_fqdn
}

output "app_service_name" {
  value = module.app_service.app_service_name
}

output "key_vault_name" {
  value = module.key_vault.key_vault_name
}

output "sql_server_fqdn" {
  value = module.sql.sql_server_fqdn
}

output "storage_account_name" {
  value = module.storage.storage_account_name
}

# =============================================================================
# Private DNS Module - Outputs
# =============================================================================

output "dns_zone_app_service_id" {
  description = "ID of the App Service Private DNS Zone"
  value       = azurerm_private_dns_zone.app_service.id
}

output "dns_zone_keyvault_id" {
  description = "ID of the Key Vault Private DNS Zone"
  value       = azurerm_private_dns_zone.keyvault.id
}

output "dns_zone_storage_blob_id" {
  description = "ID of the Storage Blob Private DNS Zone"
  value       = azurerm_private_dns_zone.storage_blob.id
}

output "dns_zone_sql_id" {
  description = "ID of the SQL Private DNS Zone"
  value       = azurerm_private_dns_zone.sql.id
}

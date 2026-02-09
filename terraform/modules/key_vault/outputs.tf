# =============================================================================
# Key Vault Module - Outputs
# =============================================================================

output "key_vault_id" {
  description = "ID of the Key Vault"
  value       = azurerm_key_vault.main.id
}

output "key_vault_name" {
  description = "Name of the Key Vault"
  value       = azurerm_key_vault.main.name
}

output "key_vault_uri" {
  description = "URI of the Key Vault"
  value       = azurerm_key_vault.main.vault_uri
}

output "secret_name" {
  description = "Name of the SQL connection string secret"
  value       = azurerm_key_vault_secret.sql_connection_string.name
}

# =============================================================================
# Key Vault Module - Main Configuration
# =============================================================================
# Creates: Key Vault, Secret, Private Endpoint, RBAC Assignments
# =============================================================================

# Key Vault
resource "azurerm_key_vault" "main" {
  name                = "${var.name_prefix}kv${var.resource_suffix}"
  location            = var.location
  resource_group_name = var.resource_group_name
  tenant_id           = var.tenant_id
  sku_name            = var.sku

  public_network_access_enabled = var.public_network_access_enabled
  soft_delete_retention_days    = var.soft_delete_retention_days
  purge_protection_enabled      = var.purge_protection_enabled
  enable_rbac_authorization     = true

  network_acls {
    default_action = var.public_network_access_enabled ? "Allow" : "Deny"
    bypass         = "AzureServices"
  }

  tags = var.tags
}

# Key Vault Private Endpoint
resource "azurerm_private_endpoint" "keyvault" {
  name                = "${var.name_prefix}-kv-pe"
  location            = var.location
  resource_group_name = var.resource_group_name
  subnet_id           = var.private_endpoint_subnet_id

  private_service_connection {
    name                           = "${var.name_prefix}-kv-psc"
    private_connection_resource_id = azurerm_key_vault.main.id
    is_manual_connection           = false
    subresource_names              = ["vault"]
  }

  private_dns_zone_group {
    name                 = "keyvault-dns-zone-group"
    private_dns_zone_ids = [var.dns_zone_id]
  }

  tags = var.tags
}

# Grant App Service access to Key Vault secrets
resource "azurerm_role_assignment" "app_keyvault_secrets" {
  scope                = azurerm_key_vault.main.id
  role_definition_name = "Key Vault Secrets User"
  principal_id         = var.app_service_principal_id
}

# Grant deployer admin access (optional - requires Owner role on Service Principal)
resource "azurerm_role_assignment" "deployer_keyvault_admin" {
  count                = var.create_deployer_role_assignment ? 1 : 0
  scope                = azurerm_key_vault.main.id
  role_definition_name = "Key Vault Administrator"
  principal_id         = var.deployer_object_id
}

# Store SQL Connection String - created in Phase 1 with public access
resource "azurerm_key_vault_secret" "sql_connection_string" {
  name         = "SqlConnectionString"
  value        = var.sql_connection_string
  key_vault_id = azurerm_key_vault.main.id
}

# =============================================================================
# Private DNS Module - Main Configuration
# =============================================================================
# Creates: Private DNS Zones for App Service, Key Vault, Storage, SQL
# =============================================================================

# Private DNS Zone for App Service
resource "azurerm_private_dns_zone" "app_service" {
  name                = var.dns_zone_app_service
  resource_group_name = var.resource_group_name

  tags = var.tags
}

resource "azurerm_private_dns_zone_virtual_network_link" "app_service" {
  name                  = "app-service-dns-link"
  resource_group_name   = var.resource_group_name
  private_dns_zone_name = azurerm_private_dns_zone.app_service.name
  virtual_network_id    = var.vnet_id
  registration_enabled  = false

  tags = var.tags
}

# Private DNS Zone for Key Vault
resource "azurerm_private_dns_zone" "keyvault" {
  name                = var.dns_zone_keyvault
  resource_group_name = var.resource_group_name

  tags = var.tags
}

resource "azurerm_private_dns_zone_virtual_network_link" "keyvault" {
  name                  = "keyvault-dns-link"
  resource_group_name   = var.resource_group_name
  private_dns_zone_name = azurerm_private_dns_zone.keyvault.name
  virtual_network_id    = var.vnet_id
  registration_enabled  = false

  tags = var.tags
}

# Private DNS Zone for Storage Account (Blob)
resource "azurerm_private_dns_zone" "storage_blob" {
  name                = var.dns_zone_storage_blob
  resource_group_name = var.resource_group_name

  tags = var.tags
}

resource "azurerm_private_dns_zone_virtual_network_link" "storage_blob" {
  name                  = "storage-blob-dns-link"
  resource_group_name   = var.resource_group_name
  private_dns_zone_name = azurerm_private_dns_zone.storage_blob.name
  virtual_network_id    = var.vnet_id
  registration_enabled  = false

  tags = var.tags
}

# Private DNS Zone for SQL Database
resource "azurerm_private_dns_zone" "sql" {
  name                = var.dns_zone_sql
  resource_group_name = var.resource_group_name

  tags = var.tags
}

resource "azurerm_private_dns_zone_virtual_network_link" "sql" {
  name                  = "sql-dns-link"
  resource_group_name   = var.resource_group_name
  private_dns_zone_name = azurerm_private_dns_zone.sql.name
  virtual_network_id    = var.vnet_id
  registration_enabled  = false

  tags = var.tags
}

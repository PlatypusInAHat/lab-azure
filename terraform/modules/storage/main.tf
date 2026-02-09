# =============================================================================
# Storage Module - Main Configuration
# =============================================================================
# Creates: Storage Account, Container, Private Endpoint, RBAC
# =============================================================================

# Storage Account
resource "azurerm_storage_account" "main" {
  name                     = lower(replace("${var.name_prefix}sa${var.resource_suffix}", "-", ""))
  location                 = var.location
  resource_group_name      = var.resource_group_name
  account_tier             = var.account_tier
  account_replication_type = var.replication_type

  public_network_access_enabled = var.public_network_access_enabled
  min_tls_version               = var.min_tls_version

  network_rules {
    default_action = var.public_network_access_enabled ? "Allow" : "Deny"
    bypass         = ["AzureServices"]
  }

  tags = var.tags
}

# Blob Container - only create when public access is enabled
# When private, App Service creates it via managed identity on first use
resource "azurerm_storage_container" "main" {
  count                 = var.public_network_access_enabled ? 1 : 0
  name                  = var.container_name
  storage_account_name  = azurerm_storage_account.main.name
  container_access_type = "private"
}

# Storage Account Private Endpoint (Blob)
resource "azurerm_private_endpoint" "storage_blob" {
  name                = "${var.name_prefix}-sa-blob-pe"
  location            = var.location
  resource_group_name = var.resource_group_name
  subnet_id           = var.private_endpoint_subnet_id

  private_service_connection {
    name                           = "${var.name_prefix}-sa-blob-psc"
    private_connection_resource_id = azurerm_storage_account.main.id
    is_manual_connection           = false
    subresource_names              = ["blob"]
  }

  private_dns_zone_group {
    name                 = "storage-blob-dns-zone-group"
    private_dns_zone_ids = [var.dns_zone_id]
  }

  tags = var.tags
}

# Grant App Service access to Storage
resource "azurerm_role_assignment" "app_storage_blob" {
  scope                = azurerm_storage_account.main.id
  role_definition_name = "Storage Blob Data Contributor"
  principal_id         = var.app_service_principal_id
}

# =============================================================================
# SQL Module - Main Configuration
# =============================================================================
# Creates: SQL Server, Database, Private Endpoint
# =============================================================================

# SQL Server
resource "azurerm_mssql_server" "main" {
  name                         = "${var.name_prefix}-sql-${var.resource_suffix}"
  location                     = var.location
  resource_group_name          = var.resource_group_name
  version                      = var.server_version
  administrator_login          = var.admin_username
  administrator_login_password = var.admin_password

  public_network_access_enabled = false

  tags = var.tags
}

# SQL Database
resource "azurerm_mssql_database" "main" {
  name           = "${var.name_prefix}-db"
  server_id      = azurerm_mssql_server.main.id
  sku_name       = var.database_sku
  max_size_gb    = var.max_size_gb
  zone_redundant = var.zone_redundant

  tags = var.tags
}

# SQL Server Private Endpoint
resource "azurerm_private_endpoint" "sql" {
  name                = "${var.name_prefix}-sql-pe"
  location            = var.location
  resource_group_name = var.resource_group_name
  subnet_id           = var.private_endpoint_subnet_id

  private_service_connection {
    name                           = "${var.name_prefix}-sql-psc"
    private_connection_resource_id = azurerm_mssql_server.main.id
    is_manual_connection           = false
    subresource_names              = ["sqlServer"]
  }

  private_dns_zone_group {
    name                 = "sql-dns-zone-group"
    private_dns_zone_ids = [var.dns_zone_id]
  }

  tags = var.tags
}

# Note: Azure Services access SQL via Private Endpoint, no firewall rule needed
# Firewall rules only work when public_network_access_enabled = true

# =============================================================================
# SQL Module - Main Configuration
# =============================================================================
# Creates: SQL Server, Database, Private Endpoint, Firewall Rules
# =============================================================================

# SQL Server
resource "azurerm_mssql_server" "main" {
  name                         = "${var.name_prefix}-sql-${var.resource_suffix}"
  location                     = var.location
  resource_group_name          = var.resource_group_name
  version                      = var.server_version
  administrator_login          = var.admin_username
  administrator_login_password = var.admin_password

  public_network_access_enabled = var.public_network_access_enabled

  tags = var.tags
}

# Allow Azure Services access (for GitHub Actions via Azure Login)
# Only created when public access is enabled (Phase 1)
resource "azurerm_mssql_firewall_rule" "allow_azure_services" {
  count            = var.public_network_access_enabled ? 1 : 0
  name             = "AllowAzureServices"
  server_id        = azurerm_mssql_server.main.id
  start_ip_address = "0.0.0.0"
  end_ip_address   = "0.0.0.0"
}

# Allow all IPs temporarily for CI/CD (Phase 1 only)
resource "azurerm_mssql_firewall_rule" "allow_all_for_cicd" {
  count            = var.public_network_access_enabled ? 1 : 0
  name             = "AllowCICD"
  server_id        = azurerm_mssql_server.main.id
  start_ip_address = "0.0.0.0"
  end_ip_address   = "255.255.255.255"
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

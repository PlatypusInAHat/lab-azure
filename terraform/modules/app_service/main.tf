# =============================================================================
# App Service Module - Main Configuration
# =============================================================================
# Creates: App Service Plan, Linux Web App, Private Endpoint
# =============================================================================

# App Service Plan
resource "azurerm_service_plan" "main" {
  name                = "${var.name_prefix}-asp"
  location            = var.location
  resource_group_name = var.resource_group_name
  os_type             = "Linux"
  sku_name            = var.sku

  tags = var.tags
}

# App Service (Linux Web App)
resource "azurerm_linux_web_app" "main" {
  name                = "${var.name_prefix}-app-${var.resource_suffix}"
  location            = var.location
  resource_group_name = var.resource_group_name
  service_plan_id     = azurerm_service_plan.main.id

  public_network_access_enabled = var.public_network_access_enabled

  identity {
    type = "SystemAssigned"
  }

  virtual_network_subnet_id = var.vnet_integration_subnet_id

  site_config {
    always_on = var.always_on

    application_stack {
      dotnet_version = var.dotnet_version
    }

    vnet_route_all_enabled = true
  }

  app_settings = var.app_settings

  tags = var.tags
}

# App Service Private Endpoint
resource "azurerm_private_endpoint" "app_service" {
  name                = "${var.name_prefix}-app-pe"
  location            = var.location
  resource_group_name = var.resource_group_name
  subnet_id           = var.private_endpoint_subnet_id

  private_service_connection {
    name                           = "${var.name_prefix}-app-psc"
    private_connection_resource_id = azurerm_linux_web_app.main.id
    is_manual_connection           = false
    subresource_names              = ["sites"]
  }

  private_dns_zone_group {
    name                 = "app-service-dns-zone-group"
    private_dns_zone_ids = [var.dns_zone_id]
  }

  tags = var.tags
}

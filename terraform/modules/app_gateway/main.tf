# =============================================================================
# Application Gateway Module - Main Configuration
# =============================================================================
# Creates: Public IP, Application Gateway
# =============================================================================

# Public IP for Application Gateway
resource "azurerm_public_ip" "app_gw" {
  name                = "${var.name_prefix}-appgw-pip"
  location            = var.location
  resource_group_name = var.resource_group_name
  allocation_method   = var.public_ip_allocation_method
  sku                 = var.public_ip_sku
  domain_name_label   = "${var.name_prefix}-${var.resource_suffix}"

  tags = var.tags
}

# Application Gateway
resource "azurerm_application_gateway" "main" {
  name                = "${var.name_prefix}-appgw"
  location            = var.location
  resource_group_name = var.resource_group_name

  sku {
    name     = var.sku
    tier     = var.sku
    capacity = var.capacity
  }

  ssl_policy {
    policy_type = "Predefined"
    policy_name = var.ssl_policy
  }

  gateway_ip_configuration {
    name      = "gateway-ip-config"
    subnet_id = var.subnet_id
  }

  frontend_ip_configuration {
    name                 = "frontend-ip-config"
    public_ip_address_id = azurerm_public_ip.app_gw.id
  }

  frontend_port {
    name = "http-port"
    port = var.http_port
  }

  backend_address_pool {
    name  = "app-service-backend-pool"
    fqdns = [var.backend_fqdn]
  }

  backend_http_settings {
    name                                = "app-service-http-settings"
    cookie_based_affinity               = "Disabled"
    port                                = var.backend_port
    protocol                            = "Https"
    request_timeout                     = var.request_timeout
    pick_host_name_from_backend_address = true
    probe_name                          = "app-service-health-probe"
  }

  probe {
    name                                      = "app-service-health-probe"
    protocol                                  = "Https"
    path                                      = "/"
    interval                                  = var.health_probe_interval
    timeout                                   = var.health_probe_timeout
    unhealthy_threshold                       = var.health_probe_unhealthy_threshold
    pick_host_name_from_backend_http_settings = true
  }

  http_listener {
    name                           = "http-listener"
    frontend_ip_configuration_name = "frontend-ip-config"
    frontend_port_name             = "http-port"
    protocol                       = "Http"
  }

  request_routing_rule {
    name                       = "http-routing-rule"
    priority                   = var.routing_rule_priority
    rule_type                  = "Basic"
    http_listener_name         = "http-listener"
    backend_address_pool_name  = "app-service-backend-pool"
    backend_http_settings_name = "app-service-http-settings"
  }

  tags = var.tags
}

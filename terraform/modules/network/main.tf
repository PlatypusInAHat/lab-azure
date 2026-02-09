# =============================================================================
# Network Module - Main Configuration
# =============================================================================
# Creates: Virtual Network, Subnets, Network Security Groups
# =============================================================================

# Virtual Network
resource "azurerm_virtual_network" "main" {
  name                = "${var.name_prefix}-vnet"
  location            = var.location
  resource_group_name = var.resource_group_name
  address_space       = var.vnet_address_space

  tags = var.tags
}

# Application Gateway Subnet
resource "azurerm_subnet" "app_gw" {
  name                 = "app-gw-subnet"
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.main.name
  address_prefixes     = [var.subnet_app_gw_prefix]
}

# VNet Integration Subnet (for App Service outbound traffic)
resource "azurerm_subnet" "vnet_integration" {
  name                 = "vnet-integration-subnet"
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.main.name
  address_prefixes     = [var.subnet_vnet_integration_prefix]

  delegation {
    name = "webapp-delegation"

    service_delegation {
      name    = "Microsoft.Web/serverFarms"
      actions = ["Microsoft.Network/virtualNetworks/subnets/action"]
    }
  }
}

# Private Endpoint Subnet
resource "azurerm_subnet" "private_endpoint" {
  name                 = "private-endpoint-subnet"
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.main.name
  address_prefixes     = [var.subnet_private_endpoint_prefix]

  private_endpoint_network_policies = "Disabled"
}

# NSG for Private Endpoint Subnet
resource "azurerm_network_security_group" "private_endpoint" {
  name                = "${var.name_prefix}-pe-nsg"
  location            = var.location
  resource_group_name = var.resource_group_name

  tags = var.tags
}

resource "azurerm_subnet_network_security_group_association" "private_endpoint" {
  subnet_id                 = azurerm_subnet.private_endpoint.id
  network_security_group_id = azurerm_network_security_group.private_endpoint.id
}

# NSG for VNet Integration Subnet
resource "azurerm_network_security_group" "vnet_integration" {
  name                = "${var.name_prefix}-vnet-int-nsg"
  location            = var.location
  resource_group_name = var.resource_group_name

  tags = var.tags
}

resource "azurerm_subnet_network_security_group_association" "vnet_integration" {
  subnet_id                 = azurerm_subnet.vnet_integration.id
  network_security_group_id = azurerm_network_security_group.vnet_integration.id
}

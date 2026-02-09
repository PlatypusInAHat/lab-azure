# =============================================================================
# Dev Environment - Main Configuration
# =============================================================================
# Orchestrates all modules for the development environment
# =============================================================================

terraform {
  required_version = ">= 1.0"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.0"
    }
  }
}

provider "azurerm" {
  features {
    key_vault {
      purge_soft_delete_on_destroy    = true
      recover_soft_deleted_key_vaults = true
    }
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
}

# -----------------------------------------------------------------------------
# Data Sources
# -----------------------------------------------------------------------------
data "azurerm_client_config" "current" {}

# Random suffix for unique names
resource "random_string" "suffix" {
  length  = 6
  special = false
  upper   = false
}

# -----------------------------------------------------------------------------
# Resource Group
# -----------------------------------------------------------------------------
resource "azurerm_resource_group" "main" {
  name     = "${var.project_name}-${var.environment}-rg"
  location = var.location
  tags     = local.common_tags
}

# -----------------------------------------------------------------------------
# Local Values
# -----------------------------------------------------------------------------
locals {
  name_prefix     = "${var.project_name}-${var.environment}"
  resource_suffix = random_string.suffix.result

  common_tags = {
    Project     = var.project_name
    Environment = var.environment
    ManagedBy   = "Terraform"
  }
}

# -----------------------------------------------------------------------------
# Network Module
# -----------------------------------------------------------------------------
module "network" {
  source = "../../modules/network"

  name_prefix         = local.name_prefix
  location            = var.location
  resource_group_name = azurerm_resource_group.main.name

  vnet_address_space             = var.vnet_address_space
  subnet_app_gw_prefix           = var.subnet_app_gw_prefix
  subnet_vnet_integration_prefix = var.subnet_vnet_integration_prefix
  subnet_private_endpoint_prefix = var.subnet_private_endpoint_prefix

  tags = local.common_tags
}

# -----------------------------------------------------------------------------
# Private DNS Module
# -----------------------------------------------------------------------------
module "private_dns" {
  source = "../../modules/private_dns"

  resource_group_name = azurerm_resource_group.main.name
  vnet_id             = module.network.vnet_id

  tags = local.common_tags
}

# -----------------------------------------------------------------------------
# SQL Module
# -----------------------------------------------------------------------------
module "sql" {
  source = "../../modules/sql"

  name_prefix         = local.name_prefix
  resource_suffix     = local.resource_suffix
  location            = var.location
  resource_group_name = azurerm_resource_group.main.name

  private_endpoint_subnet_id = module.network.subnet_private_endpoint_id
  dns_zone_id                = module.private_dns.dns_zone_sql_id

  admin_username = var.sql_admin_username
  admin_password = var.sql_admin_password
  database_sku   = var.sql_database_sku

  tags = local.common_tags
}

# -----------------------------------------------------------------------------
# App Service Module
# -----------------------------------------------------------------------------
module "app_service" {
  source = "../../modules/app_service"

  name_prefix         = local.name_prefix
  resource_suffix     = local.resource_suffix
  location            = var.location
  resource_group_name = azurerm_resource_group.main.name

  vnet_integration_subnet_id = module.network.subnet_vnet_integration_id
  private_endpoint_subnet_id = module.network.subnet_private_endpoint_id
  dns_zone_id                = module.private_dns.dns_zone_app_service_id

  sku                           = var.app_service_sku
  public_network_access_enabled = var.public_network_access_enabled

  app_settings = {
    "ConnectionStrings__DefaultConnection" = "@Microsoft.KeyVault(VaultName=${module.key_vault.key_vault_name};SecretName=SqlConnectionString)"
    "AzureStorage__AccountName"            = module.storage.storage_account_name
    "AzureStorage__ContainerName"          = module.storage.container_name
    "ASPNETCORE_ENVIRONMENT"               = var.environment == "prod" ? "Production" : "Development"
  }

  tags = local.common_tags
}

# -----------------------------------------------------------------------------
# Key Vault Module
# -----------------------------------------------------------------------------
module "key_vault" {
  source = "../../modules/key_vault"

  name_prefix         = local.name_prefix
  resource_suffix     = local.resource_suffix
  location            = var.location
  resource_group_name = azurerm_resource_group.main.name
  tenant_id           = data.azurerm_client_config.current.tenant_id

  private_endpoint_subnet_id = module.network.subnet_private_endpoint_id
  dns_zone_id                = module.private_dns.dns_zone_keyvault_id

  app_service_principal_id = module.app_service.principal_id
  deployer_object_id       = data.azurerm_client_config.current.object_id
  sql_connection_string    = module.sql.connection_string

  public_network_access_enabled = var.public_network_access_enabled

  tags = local.common_tags
}

# -----------------------------------------------------------------------------
# Storage Module
# -----------------------------------------------------------------------------
module "storage" {
  source = "../../modules/storage"

  name_prefix         = local.name_prefix
  resource_suffix     = local.resource_suffix
  location            = var.location
  resource_group_name = azurerm_resource_group.main.name

  private_endpoint_subnet_id = module.network.subnet_private_endpoint_id
  dns_zone_id                = module.private_dns.dns_zone_storage_blob_id

  app_service_principal_id = module.app_service.principal_id
  container_name           = var.blob_container_name

  public_network_access_enabled = var.public_network_access_enabled

  tags = local.common_tags
}

# -----------------------------------------------------------------------------
# Application Gateway Module
# -----------------------------------------------------------------------------
module "app_gateway" {
  source = "../../modules/app_gateway"

  name_prefix         = local.name_prefix
  resource_suffix     = local.resource_suffix
  location            = var.location
  resource_group_name = azurerm_resource_group.main.name

  subnet_id    = module.network.subnet_app_gw_id
  backend_fqdn = module.app_service.default_hostname

  sku      = var.app_gateway_sku
  capacity = var.app_gateway_capacity

  tags = local.common_tags

  depends_on = [module.app_service]
}

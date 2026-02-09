# =============================================================================
# Dev Environment - Backend Configuration
# =============================================================================
# Local backend for development. Upgrade to Azure Storage for team collaboration.
# =============================================================================

# Uncomment below for remote backend:
# terraform {
#   backend "azurerm" {
#     resource_group_name  = "tfstate-rg"
#     storage_account_name = "tfstateXXXXX"
#     container_name       = "tfstate"
#     key                  = "dev/terraform.tfstate"
#   }
# }

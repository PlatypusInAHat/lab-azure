# =============================================================================
# Terraform Backend Configuration - Development
# =============================================================================
# Remote state stored in Azure Storage
# =============================================================================

terraform {
  backend "azurerm" {
    resource_group_name  = "terraform-state-rg"
    storage_account_name = "tfstatelabazure14319852"
    container_name       = "tfstate"
    key                  = "dev.terraform.tfstate"
  }
}

# =============================================================================
# Terraform & Provider Versions
# =============================================================================
# This file defines the required Terraform version and provider versions.
# Include this in your environment configuration using a symlink or copy.
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

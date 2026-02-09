#!/bin/bash
# =============================================================================
# Bootstrap Terraform Remote State Storage
# =============================================================================
# Run this ONCE to create the storage account for Terraform state
# =============================================================================

set -e

# Configuration
RESOURCE_GROUP_NAME="terraform-state-rg"
STORAGE_ACCOUNT_NAME="tfstatelabazure$(openssl rand -hex 4)"
CONTAINER_NAME="tfstate"
LOCATION="eastasia"

echo "==========================================="
echo "🚀 BOOTSTRAP TERRAFORM REMOTE STATE"
echo "==========================================="

# Create Resource Group
echo "1️⃣  Creating Resource Group..."
az group create \
  --name $RESOURCE_GROUP_NAME \
  --location $LOCATION \
  --output none

echo "✅ Resource Group created: $RESOURCE_GROUP_NAME"

# Create Storage Account
echo ""
echo "2️⃣  Creating Storage Account..."
az storage account create \
  --name $STORAGE_ACCOUNT_NAME \
  --resource-group $RESOURCE_GROUP_NAME \
  --location $LOCATION \
  --sku Standard_LRS \
  --kind StorageV2 \
  --min-tls-version TLS1_2 \
  --allow-blob-public-access false \
  --output none

echo "✅ Storage Account created: $STORAGE_ACCOUNT_NAME"

# Create Container
echo ""
echo "3️⃣  Creating Blob Container..."
az storage container create \
  --name $CONTAINER_NAME \
  --account-name $STORAGE_ACCOUNT_NAME \
  --auth-mode login \
  --output none

echo "✅ Container created: $CONTAINER_NAME"

# Enable versioning for state recovery
echo ""
echo "4️⃣  Enabling blob versioning..."
az storage account blob-service-properties update \
  --account-name $STORAGE_ACCOUNT_NAME \
  --resource-group $RESOURCE_GROUP_NAME \
  --enable-versioning true \
  --output none

echo "✅ Blob versioning enabled"

echo ""
echo "==========================================="
echo "✅ BOOTSTRAP COMPLETE"
echo "==========================================="
echo ""
echo "📋 Update your backend.tf with:"
echo ""
echo "terraform {"
echo "  backend \"azurerm\" {"
echo "    resource_group_name  = \"$RESOURCE_GROUP_NAME\""
echo "    storage_account_name = \"$STORAGE_ACCOUNT_NAME\""
echo "    container_name       = \"$CONTAINER_NAME\""
echo "    key                  = \"dev.terraform.tfstate\"  # or prod.terraform.tfstate"
echo "  }"
echo "}"
echo ""
echo "🔐 Add to GitHub Secrets:"
echo "  AZURE_STORAGE_ACCOUNT_NAME=$STORAGE_ACCOUNT_NAME"
echo ""

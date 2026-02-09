#!/bin/bash
# =============================================================================
# Deploy Application to Azure App Service
# =============================================================================

set -e

# Configuration
RG_NAME="labazure-dev-rg"
APP_NAME=$(az webapp list --resource-group $RG_NAME --query "[0].name" -o tsv)
STORAGE_NAME=$(az storage account list --resource-group $RG_NAME --query "[0].name" -o tsv)
SQL_SERVER=$(az sql server list --resource-group $RG_NAME --query "[0].name" -o tsv)

echo "=========================================="
echo "🚀 DEPLOY APPLICATION TO AZURE"
echo "=========================================="
echo "App Service: $APP_NAME"
echo "Storage: $STORAGE_NAME"
echo "SQL Server: $SQL_SERVER"
echo ""

# Step 1: Update App Settings
echo "1️⃣  Updating App Settings..."
az webapp config appsettings set \
    --resource-group $RG_NAME \
    --name $APP_NAME \
    --settings \
    "AzureStorage__AccountName=$STORAGE_NAME" \
    --output none

echo "✅ App Settings updated"

# Step 2: Build the application
echo ""
echo "2️⃣  Building application..."
cd /mnt/d/lab-azure/app/src/UserProfileApp
dotnet restore
dotnet publish -c Release -o ./publish

echo "✅ Application built"

# Step 3: Create zip for deployment
echo ""
echo "3️⃣  Creating deployment package..."
cd publish
zip -r ../deploy.zip .
cd ..

echo "✅ Package created"

# Step 4: Deploy to Azure
echo ""
echo "4️⃣  Deploying to Azure App Service..."
az webapp deploy \
    --resource-group $RG_NAME \
    --name $APP_NAME \
    --src-path deploy.zip \
    --type zip

echo "✅ Application deployed"

# Step 5: Create blob container for user pictures
echo ""
echo "5️⃣  Creating blob container..."
az storage container create \
    --name user-pictures \
    --account-name $STORAGE_NAME \
    --auth-mode login \
    --output none 2>/dev/null || echo "Container already exists"

echo "✅ Blob container ready"

# Step 6: Upload sample images (placeholder)
echo ""
echo "6️⃣  Note: Upload sample images to container 'user-pictures'"
echo "   Files: user1.jpg, user2.jpg, user3.jpg, user4.jpg, user5.jpg"
echo "   Command: az storage blob upload --account-name $STORAGE_NAME --container-name user-pictures --name user1.jpg --file ./images/user1.jpg --auth-mode login"

# Step 7: Initialize database
echo ""
echo "7️⃣  Run database initialization:"
echo "   Connect to SQL Server and run: init-database.sql"
echo "   Connection: $SQL_SERVER.database.windows.net"

echo ""
echo "=========================================="
echo "✅ DEPLOYMENT COMPLETE"
echo "=========================================="
echo ""
echo "📌 Access application via Application Gateway:"
APP_GW_IP=$(az network public-ip show --resource-group $RG_NAME --name labazure-appgw-pip --query "ipAddress" -o tsv 2>/dev/null)
echo "   http://$APP_GW_IP"

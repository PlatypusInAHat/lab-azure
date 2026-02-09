#!/bin/bash
# =============================================================================
# Azure Infrastructure Verification Script
# Chạy sau khi terraform apply hoàn thành để kiểm tra kiến trúc
# =============================================================================

echo "=========================================="
echo "🔍 AZURE INFRASTRUCTURE VERIFICATION"
echo "=========================================="

# Variables - thay đổi nếu cần
RG_NAME="labazure-rg"

echo ""
echo "1️⃣  Kiểm tra Resource Group..."
az group show --name $RG_NAME --query "{Name:name, Location:location, State:properties.provisioningState}" -o table

echo ""
echo "2️⃣  Kiểm tra Virtual Network và Subnets..."
az network vnet show --resource-group $RG_NAME --name labazure-vnet --query "{Name:name, AddressSpace:addressSpace.addressPrefixes[0]}" -o table
az network vnet subnet list --resource-group $RG_NAME --vnet-name labazure-vnet --query "[].{Name:name, AddressPrefix:addressPrefix, Delegations:delegations[0].serviceName}" -o table

echo ""
echo "3️⃣  Kiểm tra Application Gateway (Public IP)..."
az network public-ip show --resource-group $RG_NAME --name labazure-appgw-pip --query "{Name:name, IPAddress:ipAddress, FQDN:dnsSettings.fqdn}" -o table
az network application-gateway show --resource-group $RG_NAME --name labazure-appgw --query "{Name:name, State:provisioningState, SKU:sku.name}" -o table

echo ""
echo "4️⃣  Kiểm tra App Service..."
az webapp list --resource-group $RG_NAME --query "[].{Name:name, State:state, DefaultHostname:defaultHostName, VNetIntegration:virtualNetworkSubnetId}" -o table

echo ""
echo "5️⃣  Kiểm tra Key Vault..."
az keyvault show --resource-group $RG_NAME --name labazurekv* --query "{Name:name, VaultUri:properties.vaultUri, PublicAccess:properties.publicNetworkAccess}" -o table 2>/dev/null || az keyvault list --resource-group $RG_NAME --query "[].{Name:name, VaultUri:properties.vaultUri}" -o table

echo ""
echo "6️⃣  Kiểm tra Storage Account..."
az storage account list --resource-group $RG_NAME --query "[].{Name:name, PublicAccess:publicNetworkAccess, PrimaryLocation:primaryLocation}" -o table

echo ""
echo "7️⃣  Kiểm tra SQL Server..."
az sql server list --resource-group $RG_NAME --query "[].{Name:name, FQDN:fullyQualifiedDomainName, PublicAccess:publicNetworkAccess}" -o table

echo ""
echo "8️⃣  Kiểm tra Private Endpoints..."
az network private-endpoint list --resource-group $RG_NAME --query "[].{Name:name, PrivateIP:customDnsConfigs[0].ipAddresses[0], ConnectedTo:privateLinkServiceConnections[0].privateLinkServiceId}" -o table

echo ""
echo "9️⃣  Kiểm tra Private DNS Zones..."
az network private-dns zone list --resource-group $RG_NAME --query "[].{Name:name, RecordSets:numberOfRecordSets}" -o table

echo ""
echo "🔟 Kiểm tra Network Security Groups..."
az network nsg list --resource-group $RG_NAME --query "[].{Name:name, Location:location}" -o table

echo ""
echo "=========================================="
echo "✅ VERIFICATION COMPLETE"
echo "=========================================="
echo ""
echo "📌 Để truy cập ứng dụng:"
PUBLIC_IP=$(az network public-ip show --resource-group $RG_NAME --name labazure-appgw-pip --query "ipAddress" -o tsv 2>/dev/null)
FQDN=$(az network public-ip show --resource-group $RG_NAME --name labazure-appgw-pip --query "dnsSettings.fqdn" -o tsv 2>/dev/null)
echo "   IP: http://$PUBLIC_IP"
echo "   FQDN: http://$FQDN"

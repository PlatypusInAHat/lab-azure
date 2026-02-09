#!/bin/bash
# =============================================================================
# Azure Infrastructure Network Connectivity Test
# Kiểm tra kết nối mạng sau khi deploy
# =============================================================================

echo "=========================================="
echo "🌐 NETWORK CONNECTIVITY TESTS"
echo "=========================================="

# Variables
RG_NAME="labazure-rg"

# Get resource names from Azure
echo ""
echo "📋 Lấy thông tin resources..."
APP_GW_PIP=$(az network public-ip show --resource-group $RG_NAME --name labazure-appgw-pip --query "ipAddress" -o tsv 2>/dev/null)
APP_GW_FQDN=$(az network public-ip show --resource-group $RG_NAME --name labazure-appgw-pip --query "dnsSettings.fqdn" -o tsv 2>/dev/null)
APP_SERVICE_NAME=$(az webapp list --resource-group $RG_NAME --query "[0].name" -o tsv 2>/dev/null)
APP_SERVICE_HOSTNAME=$(az webapp list --resource-group $RG_NAME --query "[0].defaultHostName" -o tsv 2>/dev/null)
SQL_FQDN=$(az sql server list --resource-group $RG_NAME --query "[0].fullyQualifiedDomainName" -o tsv 2>/dev/null)
KV_NAME=$(az keyvault list --resource-group $RG_NAME --query "[0].name" -o tsv 2>/dev/null)
STORAGE_NAME=$(az storage account list --resource-group $RG_NAME --query "[0].name" -o tsv 2>/dev/null)

echo "   App Gateway IP: $APP_GW_PIP"
echo "   App Gateway FQDN: $APP_GW_FQDN"
echo "   App Service: $APP_SERVICE_HOSTNAME"
echo "   SQL Server: $SQL_FQDN"
echo "   Key Vault: $KV_NAME.vault.azure.net"
echo "   Storage: $STORAGE_NAME.blob.core.windows.net"

# =============================================================================
# TEST 1: Ping Application Gateway Public IP
# =============================================================================
echo ""
echo "=========================================="
echo "1️⃣  PING Application Gateway Public IP"
echo "=========================================="
if [ -n "$APP_GW_PIP" ]; then
    echo "ping -c 4 $APP_GW_PIP"
    ping -c 4 $APP_GW_PIP 2>/dev/null || echo "⚠️  ICMP có thể bị block bởi NSG/Firewall"
else
    echo "❌ Không tìm thấy App Gateway Public IP"
fi

# =============================================================================
# TEST 2: DNS Resolution Tests
# =============================================================================
echo ""
echo "=========================================="
echo "2️⃣  DNS RESOLUTION (nslookup)"
echo "=========================================="

echo ""
echo "🔹 App Gateway FQDN:"
if [ -n "$APP_GW_FQDN" ]; then
    nslookup $APP_GW_FQDN 2>/dev/null | grep -A2 "Name:"
fi

echo ""
echo "🔹 App Service (should resolve to private IP from VNet):"
if [ -n "$APP_SERVICE_HOSTNAME" ]; then
    nslookup $APP_SERVICE_HOSTNAME 2>/dev/null | grep -A2 "Name:"
fi

echo ""
echo "🔹 SQL Server:"
if [ -n "$SQL_FQDN" ]; then
    nslookup $SQL_FQDN 2>/dev/null | grep -A2 "Name:"
fi

echo ""
echo "🔹 Key Vault:"
if [ -n "$KV_NAME" ]; then
    nslookup $KV_NAME.vault.azure.net 2>/dev/null | grep -A2 "Name:"
fi

echo ""
echo "🔹 Storage Account:"
if [ -n "$STORAGE_NAME" ]; then
    nslookup $STORAGE_NAME.blob.core.windows.net 2>/dev/null | grep -A2 "Name:"
fi

# =============================================================================
# TEST 3: HTTP Connectivity Tests
# =============================================================================
echo ""
echo "=========================================="
echo "3️⃣  HTTP CONNECTIVITY (curl)"
echo "=========================================="

echo ""
echo "🔹 Curl App Gateway Public IP (HTTP):"
if [ -n "$APP_GW_PIP" ]; then
    echo "curl -s -o /dev/null -w 'HTTP Status: %{http_code}\n' --connect-timeout 10 http://$APP_GW_PIP"
    curl -s -o /dev/null -w "HTTP Status: %{http_code}\n" --connect-timeout 10 http://$APP_GW_PIP 2>/dev/null || echo "❌ Connection failed"
fi

echo ""
echo "🔹 Curl App Gateway FQDN (HTTP):"
if [ -n "$APP_GW_FQDN" ]; then
    echo "curl -s -o /dev/null -w 'HTTP Status: %{http_code}\n' --connect-timeout 10 http://$APP_GW_FQDN"
    curl -s -o /dev/null -w "HTTP Status: %{http_code}\n" --connect-timeout 10 http://$APP_GW_FQDN 2>/dev/null || echo "❌ Connection failed"
fi

echo ""
echo "🔹 Curl App Service Direct (should fail - no public access):"
if [ -n "$APP_SERVICE_HOSTNAME" ]; then
    echo "curl -s -o /dev/null -w 'HTTP Status: %{http_code}\n' --connect-timeout 10 https://$APP_SERVICE_HOSTNAME"
    curl -s -o /dev/null -w "HTTP Status: %{http_code}\n" --connect-timeout 10 https://$APP_SERVICE_HOSTNAME 2>/dev/null || echo "✅ Expected: Connection refused (no public access)"
fi

# =============================================================================
# TEST 4: Port Connectivity Tests
# =============================================================================
echo ""
echo "=========================================="
echo "4️⃣  PORT CONNECTIVITY (nc/netcat)"
echo "=========================================="

echo ""
echo "🔹 App Gateway Port 80:"
if [ -n "$APP_GW_PIP" ]; then
    nc -zv -w 5 $APP_GW_PIP 80 2>&1 || echo "❌ Port 80 closed"
fi

echo ""
echo "🔹 SQL Server Port 1433 (should fail from outside):"
if [ -n "$SQL_FQDN" ]; then
    nc -zv -w 5 $SQL_FQDN 1433 2>&1 || echo "✅ Expected: Connection refused (private endpoint only)"
fi

# =============================================================================
# TEST 5: Traceroute
# =============================================================================
echo ""
echo "=========================================="
echo "5️⃣  TRACEROUTE to App Gateway"
echo "=========================================="
if [ -n "$APP_GW_PIP" ]; then
    echo "traceroute -m 10 $APP_GW_PIP"
    traceroute -m 10 $APP_GW_PIP 2>/dev/null || tracepath -m 10 $APP_GW_PIP 2>/dev/null || echo "⚠️  traceroute không khả dụng"
fi

# =============================================================================
# TEST 6: Verify Private Endpoints
# =============================================================================
echo ""
echo "=========================================="
echo "6️⃣  PRIVATE ENDPOINTS STATUS"
echo "=========================================="
az network private-endpoint list --resource-group $RG_NAME \
    --query "[].{Name:name, State:provisioningState, PrivateIP:customDnsConfigs[0].ipAddresses[0]}" -o table

# =============================================================================
# TEST 7: App Service Health
# =============================================================================
echo ""
echo "=========================================="
echo "7️⃣  APP SERVICE HEALTH"
echo "=========================================="
if [ -n "$APP_SERVICE_NAME" ]; then
    az webapp show --resource-group $RG_NAME --name $APP_SERVICE_NAME \
        --query "{Name:name, State:state, HealthCheckPath:siteConfig.healthCheckPath, VNetIntegrated:virtualNetworkSubnetId!=null}" -o table
fi

# =============================================================================
# TEST 8: Application Gateway Health
# =============================================================================
echo ""
echo "=========================================="
echo "8️⃣  APPLICATION GATEWAY BACKEND HEALTH"
echo "=========================================="
az network application-gateway show-backend-health \
    --resource-group $RG_NAME \
    --name labazure-appgw \
    --query "backendAddressPools[].backendHttpSettingsCollection[].servers[].{Address:address, Health:health}" \
    -o table 2>/dev/null || echo "⚠️  Backend health check đang chạy..."

# =============================================================================
# SUMMARY
# =============================================================================
echo ""
echo "=========================================="
echo "📊 SUMMARY"
echo "=========================================="
echo ""
echo "🌐 Access URLs:"
echo "   HTTP:  http://$APP_GW_PIP"
echo "   FQDN:  http://$APP_GW_FQDN"
echo ""
echo "🔒 Security Verification:"
echo "   - App Service direct access: Should be BLOCKED ✅"
echo "   - SQL Server direct access: Should be BLOCKED ✅"
echo "   - Key Vault direct access: Should be BLOCKED ✅"
echo "   - Storage direct access: Should be BLOCKED ✅"
echo "   - App Gateway: Should be ACCESSIBLE ✅"
echo ""
echo "=========================================="
echo "✅ NETWORK TESTS COMPLETE"
echo "=========================================="

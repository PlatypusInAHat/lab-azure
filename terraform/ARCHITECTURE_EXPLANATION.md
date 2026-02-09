# Azure Infrastructure - Architecture Explanation
# Giải thích chi tiết kiến trúc hạ tầng Azure

## 📋 Tổng quan

Kiến trúc này triển khai một ứng dụng web trên Azure với các đặc điểm:
- **Bảo mật cao**: Chỉ Application Gateway có Public IP
- **Private connectivity**: Tất cả services kết nối qua Private Endpoints
- **Secret management**: Connection strings được lưu trong Key Vault

---

## 🏗️ Sơ đồ kiến trúc

```
                                    ┌─────────────────────────────────────────────────────────────┐
                                    │                         VNet (10.0.0.0/16)                  │
                                    │                                                             │
    ┌──────┐                        │  ┌─────────────────────────────────────────────────────┐    │
    │      │                        │  │           VNet Integration Subnet (10.0.2.0/24)     │    │
    │ User │                        │  │                                                     │    │
    │      │                        │  │              ┌──────────────────┐                   │    │
    └──┬───┘                        │  │              │ Virtual Interface│ ◄─── App Service  │    │
       │                            │  │              │  (Outbound only) │      gửi request  │    │
       │ HTTP:80                    │  │              └────────┬─────────┘      ra ngoài     │    │
       ▼                            │  └───────────────────────┼─────────────────────────────┘    │
┌─────────────┐                     │                          │                                  │
│  Public IP  │                     │  ┌───────────────────────┼─────────────────────────────┐    │
│ (Static)    │                     │  │    Private Endpoint Subnet (10.0.3.0/24)            │    │
└──────┬──────┘                     │  │                       │                             │    │
       │                            │  │    ┌──────────────────┼─────────────────────┐       │    │
       ▼                            │  │    │                  ▼                     │       │    │
┌─────────────────┐                 │  │    │   ┌─────────┐ ┌─────────┐ ┌─────────┐  │       │    │
│  Application    │ app-gw-subnet   │  │    │   │ Key     │ │ Storage │ │ SQL DB  │  │       │    │
│  Gateway        │ (10.0.1.0/24)   │  │    │   │ Vault   │ │ Account │ │ Private │  │       │    │
│  (Standard_v2)  │─────────────────┼──┼────┼──►│ PE      │ │ PE      │ │ Endpoint│  │       │    │
└────────┬────────┘                 │  │    │   └────┬────┘ └────┬────┘ └────┬────┘  │       │    │
         │                          │  │    │        │           │           │       │       │    │
         │ HTTPS:443                │  │    └────────┼───────────┼───────────┼───────┘       │    │
         ▼                          │  │             │           │           │               │    │
   ┌───────────┐                    │  │  ┌──────────▼──┐ ┌──────▼──────┐ ┌──▼─────────┐     │    │
   │ App       │ ◄──────────────────┼──┼──┤ App Service │ │             │ │            │     │    │
   │ Service   │    Private         │  │  │ Private     │ │             │ │            │     │    │
   │ PE        │    Endpoint        │  │  │ Endpoint    │ │             │ │            │     │    │
   └───────────┘                    │  └──┴─────────────┴─┴─────────────┴─┴────────────┴─────┘    │
                                    └─────────────────────────────────────────────────────────────┘
                                                        │           │           │
                                                        ▼           ▼           ▼
                                                 ┌───────────┐ ┌─────────┐ ┌──────────┐
                                                 │ Key Vault │ │ Storage │ │ Azure    │
                                                 │           │ │ Account │ │ SQL DB   │
                                                 └───────────┘ └─────────┘ └──────────┘
```

---

## 📁 Cấu trúc Terraform Files

| File | Mục đích |
|------|----------|
| `main.tf` | Provider configuration, Resource Group |
| `variables.tf` | Định nghĩa các biến |
| `network.tf` | VNet, 3 Subnets, NSGs |
| `dns.tf` | 4 Private DNS Zones |
| `appgateway.tf` | Application Gateway + Public IP |
| `appservice.tf` | App Service Plan + Web App + PE |
| `keyvault.tf` | Key Vault + Secret + PE |
| `storage.tf` | Storage Account + PE |
| `sql.tf` | SQL Server + Database + PE |
| `outputs.tf` | Output values |

---

## 🔒 Chi tiết từng Component

### 1. Virtual Network (`network.tf`)

**VNet**: `labazure-vnet` (10.0.0.0/16)

| Subnet | CIDR | Mục đích |
|--------|------|----------|
| `app-gw-subnet` | 10.0.1.0/24 | Application Gateway |
| `vnet-integration-subnet` | 10.0.2.0/24 | App Service VNet Integration (outbound) |
| `private-endpoint-subnet` | 10.0.3.0/24 | Tất cả Private Endpoints |

**VNet Integration Subnet** có delegation cho `Microsoft.Web/serverFarms` để App Service có thể sử dụng.

---

### 2. Application Gateway (`appgateway.tf`)

- **SKU**: Standard_v2 (hỗ trợ autoscaling)
- **Public IP**: Static, Standard SKU
- **Frontend**: HTTP port 80
- **Backend**: App Service Private Endpoint (HTTPS 443)
- **Health Probe**: Kiểm tra `/` path

**Luồng traffic**:
```
User → Public IP → App Gateway → App Service PE → App Service
```

---

### 3. App Service (`appservice.tf`)

- **Plan**: Linux, SKU S1
- **Runtime**: .NET 8.0
- **VNet Integration**: Kết nối với `vnet-integration-subnet`
- **Public Access**: DISABLED
- **Managed Identity**: System-assigned

**Connection String từ Key Vault**:
```hcl
"@Microsoft.KeyVault(VaultName=labazurekv...;SecretName=SqlConnectionString)"
```

**Hai loại kết nối**:
1. **Inbound** (từ App Gateway): Qua Private Endpoint trong `private-endpoint-subnet`
2. **Outbound** (đến SQL, KV, Storage): Qua VNet Integration trong `vnet-integration-subnet`

---

### 4. Key Vault (`keyvault.tf`)

- **SKU**: Standard
- **Public Access**: DISABLED
- **Network ACLs**: Default Deny
- **Soft Delete**: 7 ngày

**Secret được lưu**:
- `SqlConnectionString`: Connection string đến Azure SQL Database

**RBAC Roles**:
- App Service → `Key Vault Secrets User`
- Deployer → `Key Vault Administrator`

---

### 5. Storage Account (`storage.tf`)

- **Tier**: Standard LRS
- **Public Access**: DISABLED
- **TLS**: Minimum 1.2
- **Private Endpoint**: Blob subresource

**RBAC**:
- App Service → `Storage Blob Data Contributor`

---

### 6. Azure SQL Database (`sql.tf`)

- **Server Version**: 12.0
- **Database SKU**: Basic (2GB)
- **Public Access**: DISABLED

**Connection String format**:
```
Server=tcp:<server>.database.windows.net,1433;
Initial Catalog=labazure-db;
User ID=<admin>;
Password=<password>;
Encrypt=True;
```

---

### 7. Private DNS Zones (`dns.tf`)

| DNS Zone | Service |
|----------|---------|
| `privatelink.azurewebsites.net` | App Service |
| `privatelink.vaultcore.azure.net` | Key Vault |
| `privatelink.blob.core.windows.net` | Storage Account |
| `privatelink.database.windows.net` | SQL Database |

Mỗi zone được link với VNet để resolve private IPs.

---

## 🔐 Security Features

| Feature | Status | Giải thích |
|---------|--------|------------|
| **No Public IP** (trừ App GW) | ✅ | Chỉ App Gateway có public access |
| **Private Endpoints** | ✅ | Tất cả services kết nối private |
| **VNet Integration** | ✅ | App Service outbound qua VNet |
| **Key Vault Secrets** | ✅ | Connection string không hardcode |
| **Managed Identity** | ✅ | Không cần service principal |
| **Network ACLs** | ✅ | Default Deny trên tất cả services |

---

## ✅ Verification Checklist

Sau khi deploy, kiểm tra:

- [ ] Application Gateway có Public IP
- [ ] App Service `publicNetworkAccess = false`
- [ ] Key Vault `publicNetworkAccess = false`
- [ ] Storage Account `publicNetworkAccess = false`
- [ ] SQL Server `publicNetworkAccess = false`
- [ ] 4 Private Endpoints đều ở trạng thái `Succeeded`
- [ ] 4 Private DNS Zones có records
- [ ] App Service có thể đọc Key Vault secret
- [ ] Truy cập app qua App Gateway Public IP

---

## 🔄 Two-Phase Deployment (Triển khai 2-phase)

Do Terraform cần public access để tạo các **data-plane resources** (Key Vault secrets, Storage containers), chúng ta sử dụng chiến lược 2-phase:

| Phase | Public Access | Mục đích |
|-------|---------------|----------|
| **Phase 1** | ✅ Enabled | Tạo Key Vault secrets, Storage containers |
| **Phase 2** | ❌ Disabled | Khóa lại, chỉ AppGW public |

### Files

| File | Mục đích |
|------|----------|
| `phase1-public.tfvars` | Enable public access |
| `phase2-private.tfvars` | Disable public access |
| `deploy-2phase.ps1` | Script tự động hóa |

### Usage

```powershell
# Cách 1: Dùng script tự động
.\deploy-2phase.ps1                    # Interactive
.\deploy-2phase.ps1 -AutoApprove       # Auto-approve cả 2 phase
.\deploy-2phase.ps1 -Phase1Only        # Chỉ Phase 1
.\deploy-2phase.ps1 -Phase2Only        # Chỉ Phase 2 (lock down)

# Cách 2: Chạy manual
terraform apply -var-file="terraform.tfvars" -var-file="phase1-public.tfvars"
terraform apply -var-file="terraform.tfvars" -var-file="phase2-private.tfvars"
```

---

## 🚀 Commands

```bash
# Deploy
cd /mnt/d/lab-azure/terraform
terraform apply -auto-approve

# Verify
chmod +x verify-infrastructure.sh
./verify-infrastructure.sh

# Destroy
terraform destroy -auto-approve
```

---

## 📊 Estimated Costs (Dev/Test)

| Resource | SKU | Est. Monthly Cost |
|----------|-----|-------------------|
| App Service Plan | S1 | ~$55 |
| Application Gateway | Standard_v2 (2 instances) | ~$150 |
| SQL Database | Basic | ~$5 |
| Key Vault | Standard | ~$0.03/10K ops |
| Storage Account | LRS | ~$0.02/GB |
| Private Endpoints | 4x | ~$30 |

**Total**: ~$240/month (có thể giảm bằng cách dùng smaller SKUs)

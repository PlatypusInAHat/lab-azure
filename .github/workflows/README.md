# GitHub Actions CI/CD for Azure Infrastructure

## Workflows

### 1. Infrastructure (Terraform)
- `terraform-plan.yml` - Runs on PR để review changes
- `terraform-apply.yml` - Applies khi merge vào main

### 2. Application  
- `deploy-app.yml` - Build và deploy .NET app

## Prerequisites

1. **Azure Service Principal**
   ```bash
   az ad sp create-for-rbac --name "github-actions-sp" \
     --role contributor \
     --scopes /subscriptions/{subscription-id} \
     --sdk-auth
   ```

2. **GitHub Secrets**
   - `AZURE_CREDENTIALS` - JSON output từ command trên
   - `SQL_ADMIN_PASSWORD` - SQL password
   - `AZURE_SUBSCRIPTION_ID` - Subscription ID

## Workflow Flow

```
PR Created → terraform plan → Review
PR Merged → terraform apply (Phase 1) → deploy app → terraform apply (Phase 2)
```

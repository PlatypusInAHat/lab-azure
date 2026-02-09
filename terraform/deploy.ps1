# =============================================================================
# Deploy Script for Modular Terraform
# =============================================================================
# Usage:
#   .\deploy.ps1                     # Deploy dev (interactive)
#   .\deploy.ps1 -Env prod           # Deploy prod
#   .\deploy.ps1 -AutoApprove        # Auto-approve
#   .\deploy.ps1 -Phase2             # Phase 2 (lock down)
#   .\deploy.ps1 -Destroy            # Destroy infrastructure
# =============================================================================

param(
    [ValidateSet("dev", "prod")]
    [string]$Env = "dev",
    [switch]$AutoApprove,
    [switch]$Phase2,
    [switch]$Destroy,
    [switch]$PlanOnly
)

$ErrorActionPreference = "Stop"
$envPath = Join-Path $PSScriptRoot "envs\$Env"

# Check if terraform.tfvars exists
$tfvarsPath = Join-Path $envPath "terraform.tfvars"
if (-not (Test-Path $tfvarsPath)) {
    Write-Host "ERROR: terraform.tfvars not found!" -ForegroundColor Red
    Write-Host "Copy terraform.tfvars.example to terraform.tfvars and update values:" -ForegroundColor Yellow
    Write-Host "  cp $envPath\terraform.tfvars.example $tfvarsPath" -ForegroundColor Cyan
    exit 1
}

Push-Location $envPath
try {
    Write-Host "=== Environment: $Env ===" -ForegroundColor Cyan
    Write-Host "Working directory: $envPath" -ForegroundColor Gray

    # Initialize
    Write-Host "`n[1/3] Initializing Terraform..." -ForegroundColor Yellow
    terraform init -upgrade

    # Set public_network_access based on phase
    $publicAccess = if ($Phase2) { "false" } else { "true" }
    $phaseLabel = if ($Phase2) { "Phase 2 (PRIVATE)" } else { "Phase 1 (PUBLIC)" }
    Write-Host "`n[2/3] $phaseLabel - public_network_access_enabled=$publicAccess" -ForegroundColor Magenta

    # Build command
    $approveFlag = if ($AutoApprove) { "-auto-approve" } else { "" }

    if ($Destroy) {
        Write-Host "`n[3/3] DESTROYING infrastructure..." -ForegroundColor Red
        $cmd = "terraform destroy -var=`"public_network_access_enabled=$publicAccess`" $approveFlag"
    } elseif ($PlanOnly) {
        Write-Host "`n[3/3] Planning changes..." -ForegroundColor Green
        $cmd = "terraform plan -var=`"public_network_access_enabled=$publicAccess`""
    } else {
        Write-Host "`n[3/3] Applying changes..." -ForegroundColor Green
        $cmd = "terraform apply -var=`"public_network_access_enabled=$publicAccess`" $approveFlag"
    }

    Write-Host "Running: $cmd" -ForegroundColor Gray
    Invoke-Expression $cmd

    if ($LASTEXITCODE -eq 0 -and -not $PlanOnly -and -not $Destroy) {
        Write-Host "`n=== Deployment Complete ===" -ForegroundColor Green
        terraform output
    }
} finally {
    Pop-Location
}
